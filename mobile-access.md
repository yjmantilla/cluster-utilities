# Refreshing cluster auth from your phone (for headless agents on a workstation)

**Purpose.** You run **agents** (Claude Code or similar) on an always-on home **workstation**,
and they drive an Alliance cluster (`fir`, `trillium`, …) over SSH — `sbatch`, `squeue`,
`rsync`, `git pull`. To avoid a Duo prompt on every call they reuse a shared SSH
**ControlMaster** socket. The problem: when that socket dies (network blip, idle, login-node
reset), the next non-interactive `ssh cluster …` hits a Duo prompt **no agent can answer**,
and the agent stalls. This guide sets things up so that:

- the shared master stays alive as long as possible (refreshes are rare),
- agents **fail fast and report** "MFA refresh needed" instead of hanging, and
- you can do that refresh in ~10 seconds **from your phone** — one command, one Duo tap.

```
  iPhone  ──SSH (Termius)──►  home workstation  ──ssh (shared master, Duo)──►  cluster
 (remote refresh button       (agents run here;                               (fir /
  + Duo approver)              they reuse the master)                          trillium)
```

The **hard constraint**: MFA is *designed* to need a human tap — you can't (and shouldn't)
automate it away. So the goal is to make that tap **rare and phone-doable**, not to bypass it.

> A secondary use — actually driving the cluster by hand from the phone — is covered near the
> end. The setup is the same; most of the time you'll only ever run the one refresh command.

> **⚠️ Fill these in.** `<you>` = workstation username, `<workstation>` = its Tailscale name,
> `<user>` = your Alliance/CCDB username, `<cluster>` = your SSH alias (`fir`, `trillium`, …).
> Commands assume an **Arch-based** workstation (`pacman`; use `apt`/`dnf` elsewhere). The
> `systemctl` lines are the same on any systemd Linux.

---

## TL;DR

1. **Workstation:** SSH on, Tailscale up, a long-lived shared master. The two helper scripts
   stay in this repo's `bin/` and are called by full path (no install).
   ```bash
   sudo systemctl enable --now sshd
   sudo pacman -S --needed tailscale tmux
   sudo systemctl enable --now tailscaled && sudo tailscale up
   ```
   Add the ControlMaster block to `~/.ssh/config` (§ "One-time setup" step 4).
2. **Phone:** **Termius**, **Tailscale** (same account), **Duo Mobile** (already installed).
3. **Agents** call `cluster-run <host> <cmd>` (never bare `ssh`). On master-down they exit 42
   and say so — optionally buzzing your phone via ntfy.
4. **Refresh:** phone → Termius → workstation → `cluster-login <host>` → approve the Duo push.

---

## Primary use case: keeping headless agents authenticated

> **Invoking the helpers.** `cluster-run` and `cluster-login` live in this repo's `bin/`. Call
> them by their **full path** — e.g. `~/code/cluster-utilities/bin/cluster-login fir` — no
> install and no `PATH` change needed. Below, `<repo>` is your cluster-utilities checkout
> (e.g. `~/code/cluster-utilities`); the short names `cluster-run`/`cluster-login` are
> shorthand for `<repo>/bin/cluster-run` etc.

### The three pieces

**1. A long-lived, shared master.** In the workstation's `~/.ssh/config`:
```sshconfig
Host *
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist yes            # keep the master after you exit, until the link dies
  ServerAliveInterval 60
  ServerAliveCountMax 30        # ride out ~30 min of network blips before dropping
```
The master now survives your logout and idle time; it only truly dies on a real
disconnect or a login-node reset — which is the only time a re-tap is needed.

**2. Agents call a wrapper that never hangs** — `cluster-run` (in this repo's `bin/`):
```bash
cluster-run fir squeue --me
cluster-run trillium sbatch --export=ALL job.sbatch
```
Master up → runs instantly over the shared socket, no MFA. Master down → **exit 42** with a
clear message (and an optional phone ping), so the agent *reports* the problem instead of
freezing on an un-answerable Duo prompt. Internally it does `ssh -O check` then
`ssh -o BatchMode=yes` (BatchMode = never prompt).

> Tell your agents — via their project/`CLAUDE.md` rules — to use `cluster-run` for **every**
> cluster call and to **stop and notify you on exit 42**, not retry. This does not change the
> usual rule of showing the exact command before any `sbatch`/`git push`.

**3. The phone refresh button** — `cluster-login` (in this repo's `bin/`):
```bash
cluster-login fir        # clears any dead socket, logs in (approve Duo), leaves master up
```
It runs `ssh -t <host> true` — the `-t` forces a PTY so the Duo prompt works — then exits,
and `ControlPersist yes` keeps the master alive in the background for the agents. If your
Duo shows an option menu (Alliance does — e.g. type `2` for push), you type that in Termius,
then approve the push in Duo Mobile.

### Optional: get pinged instead of polling

So you don't have to guess when to refresh, set `NTFY_TOPIC` in the agents' environment and
install the [ntfy](https://ntfy.sh) app on the phone (subscribe to the same private topic).
`cluster-run` then POSTs its "master is DOWN — needs an MFA refresh" message on master-down;
your phone buzzes → open Termius → `cluster-login <host>` → tap Duo. That's the whole loop.

### The refresh loop, end to end

```
agent: cluster-run fir squeue        # master died → exit 42 → (ntfy buzzes your phone)
you:   Termius → <workstation> → cluster-login fir → approve Duo push → "Master running"
agent: cluster-run fir squeue        # back on the shared socket, no MFA — resumes
```

---

## The mental model: your phone wears two hats

When you SSH from the phone to the workstation and run `cluster-login`, the phone is doing
**two independent jobs at once**:

1. **Thin client to the workstation's terminal.** The shell (and the agents) *run on the
   workstation*. Termius is only a window; nothing computes on the phone.
2. **Duo MFA approver.** The cluster's login server fires the Duo push to your enrolled
   phone. That push is **out-of-band** — it does not travel through the terminal. Duo Mobile
   shows a notification, you tap **Approve**, and the login (shown in Termius) completes.

So the on-phone loop is: Termius (running `cluster-login`) → app-switch to Duo Mobile (tap
Approve) → app-switch back. The connection **holds and waits** while you're in Duo.

## Why this needs no mosh

> The agents — and any hands-on `ssh <cluster>` — run **on the workstation**, not the phone.
> When the phone sleeps or changes networks, only the phone→workstation link drops; the
> workstation, its agents, and the cluster master are untouched. You just reopen Termius when
> you next need to refresh. (`tmux` gives the same lossless property to any interactive work
> you do by hand — see the secondary use case.) mosh would only smooth the phone→workstation
> reconnect; it's an optional convenience, not a requirement.

---

## What to install and why

### On the workstation (the always-on home machine)

| Package | Why | Required? |
|---|---|---|
| **openssh (`sshd`)** | The door — lets the phone open a shell on the workstation. | **Yes** |
| **tailscale** | Private mesh VPN so the phone reaches the workstation over cellular with no port-forwarding, nothing public. The one thing Termius can't do itself. | **Yes** (off home Wi-Fi) |
| **tmux** | Persistent sessions for any hands-on work (survives phone disconnects). | Recommended |
| `cluster-run` / `cluster-login` | The agent wrapper + refresh button (this repo's `bin/`). | **Yes** |
| mosh | Seamless phone↔workstation reconnect. Needs a client that supports it (Blink, not Termius). | Optional |

### On the phone

| App | Role | Notes |
|---|---|---|
| **Tailscale** | The network | Same account as the workstation. |
| **Termius** | The terminal (SSH client) | Free tier is enough; also does SFTP. |
| **Duo Mobile** | MFA approver | Already installed for the cluster — it gets the push. |
| ntfy | Optional master-down alerts | Subscribe to your private `NTFY_TOPIC`. |

---

## One-time setup

### 1. Workstation base
```bash
sudo systemctl enable --now sshd
sudo pacman -S --needed tailscale tmux
sudo systemctl enable --now tailscaled
sudo tailscale up                       # opens a login URL; approve in your browser once
tailscale status                        # note the machine's name (<workstation>) + 100.x IP
```
No firewall is enabled by default on most Arch installs; over Tailscale you never expose
port 22 publicly.

### 2. Phone
Install **Tailscale** (sign in, confirm the workstation appears), **Termius**, and confirm
**Duo Mobile** is enrolled.

### 3. Auth: a normal SSH key from Termius (most predictable)
1. Termius: **Keychain → New Key → Generate**, copy the **public** key.
2. Workstation: append it to `~/.ssh/authorized_keys`.
3. Termius host: **Address** = the MagicDNS name `<workstation>` (or the `100.x.y.z` tailnet
   IP if the name won't resolve), **User** = `<you>`, **Key** = the one you generated. Set
   **Keep-Alive** ≈ 30–60 s.

### 4. Shared master + helper scripts
Add the `Host *` ControlMaster block (above) plus per-cluster aliases to `~/.ssh/config`:
```sshconfig
Host fir
  HostName fir.alliancecan.ca
  User <user>
  IdentityFile ~/.ssh/id_ed25519

Host trillium
  HostName trillium.alliancecan.ca      # CPU login; trillium-gpu.alliancecan.ca for GPU
  User <user>
  IdentityFile ~/.ssh/id_ed25519
```
The helpers stay in `<repo>/bin/` and are invoked by full path (e.g.
`~/code/cluster-utilities/bin/cluster-login fir`) — no install, no `PATH` change. Upload your
**public** key to the cluster via the CCDB portal — a CCDB key does **not** exempt you from Duo.

---

## Secondary use case: driving the cluster by hand from the phone

Same setup; occasionally you want to poke around yourself, not just refresh:
```bash
# Termius → workstation → a persistent session, so a phone drop loses nothing:
tmux new -A -s cluster
ssh fir                    # interactive; Duo push → approve → in (this also opens the master)
squeue --me ; tail -f logs/…
ssh fir true               # reuses the master — no Duo
```
Keep hands-on work inside `tmux` on the workstation: lock the phone or lose signal, then
reconnect and `tmux new -A -s cluster` puts you back exactly where you were, no new Duo.

### Optional step-ups
- **Seamless reconnect (mosh):** `sudo pacman -S mosh` + a mosh-capable client (Blink), then
  `mosh <workstation> -- tmux new -A -s cluster`. Convenience only; tmux already prevents loss.
- **Browser terminal:** run **ttyd** (`ttyd -p 7681 tmux new -A -s cluster`) or **code-server**
  on the workstation and open it in the phone's browser over Tailscale — no SSH app at all.

---

## Do you even need Termius and Tailscale?

For the pure refresh button, not strictly — it depends on where you are and how much typing
you want to avoid. The two apps solve different things:

- **Tailscale = reachability.** Needed only to reach the workstation from **outside** your
  home LAN. If you only ever refresh while on home Wi-Fi, connect to the workstation's LAN IP
  and skip Tailscale.
- **Termius = a terminal.** Needed to type `cluster-login` (and for any ad-hoc work). A
  *trigger* can replace it — but mind the Duo caveat below.

**Lighter, terminal-free trigger.** The only thing that must happen is "run `cluster-login`
on the workstation, then I approve the push," so you can skip the shell:
```bash
# workstation subscribes and runs the refresh on message (systemd service or tmux):
ntfy subscribe <your-private-topic> '<repo>/bin/cluster-login fir'
```
The phone *publishes* to that topic (ntfy app button or an iOS Shortcut) → workstation runs
`cluster-login` → Duo push → you approve in Duo Mobile. ntfy.sh brokers both directions, so
**no VPN and no SSH client** — just Duo Mobile + a way to publish.

> **⚠️ Duo-menu caveat (applies to Alliance).** If your Duo shows an option menu (you type
> e.g. `2` for push), a headless trigger has no terminal to type it into and `cluster-login`
> stalls at the menu. Two ways out:
> 1. **Keep interactive Termius** — you type the option in the terminal, then approve the
>    push. Robust, no extra parts. **(recommended)**
> 2. **Auto-answer with `expect`** so the trigger picks the option for you (you still approve
>    the push on Duo Mobile). Wrap this as `cluster-login-auto` and point the subscriber at it:
>    ```bash
>    expect -c 'spawn ssh -t fir true; expect -re {option.*: } { send "2\r" }; expect eof'
>    ```
>    Tune the regex/number to your Duo prompt. Buys "no typing" at the cost of a fragile
>    prompt-match and a daemon to keep running.

**Bottom line:** because Alliance Duo needs a typed option, the reliable path is **Termius**
(plus **Tailscale** if you're ever away from home). The trigger-only path works only with the
`expect` auto-answer.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Agent hangs on a cluster call | Bare `ssh` hit a Duo prompt with no one to answer | Route all agent calls through `cluster-run` (BatchMode + fail-fast). |
| `cluster-run` exits 42 | The shared master is down | From the phone: `cluster-login <host>`, approve Duo. |
| `ssh: Could not resolve hostname trillium` | No alias / bare name isn't DNS | Use the FQDN, or add the `Host` block (§4). |
| Termius can't reach the workstation off home Wi-Fi | No VPN; LAN IP only routes on the LAN | Both devices on Tailscale, same account; check `tailscale status`. |
| Termius won't resolve `<workstation>` MagicDNS name | App not using the tailnet resolver | Use the `100.x.y.z` tailnet IP from `tailscale status`. |
| `Permission denied (keyboard-interactive)` on a later call | The master expired mid-session | `cluster-login <host>` once to re-open it. |
| No Duo push arrives | Duo Mobile offline / wrong device | Ensure the phone has data + Duo Mobile logged in; check the enrolled device in CCDB. |
| SSH to the workstation refused | `sshd` not running | `sudo systemctl enable --now sshd`. |

---

## Notes & hygiene

- **Don't try to automate the Duo tap.** Storing bypass/HOTP seeds to script MFA defeats its
  purpose and likely violates Alliance policy. This design keeps the human tap *rare* and
  *phone-doable* instead.
- **Never expose port 22 to the public internet** — use Tailscale for the phone→workstation
  hop. **The cluster still requires Duo** regardless; Tailscale governs only that first hop.
- Usual cluster rules still apply on the far end: don't compute on login nodes, gate expensive
  jobs behind a smoke test, show the command before any `sbatch`/`git push`. See `AGENT.md`.
