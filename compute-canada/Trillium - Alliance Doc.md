---
title: "Trillium - Alliance Doc"
source: "https://docs.alliancecan.ca/wiki/Trillium"
author:
published:
created: 2026-07-11
description:
tags:
  - "clippings"
---
Availability: Aug/07 2025 Login nodes
- CPU subcluster: **trillium.alliancecan.ca**
- GPU subcluster: **trillium-gpu.alliancecan.ca**
Globus collections: **[alliancecan#trillium](https://app.globus.org/file-manager?origin_id=ad462f99-8436-42b4-adc6-3644e36c1b67)** (file system)

**[alliancecan#hpss](https://app.globus.org/file-manager?origin_id=c55ce750-19d6-4a42-9c30-6a58f06bec7a)** (archive/nearline)

Data transfer nodes (rsync, scp, sftp,...): **tri-dm{1,2,3,4}.scinet.utoronto.ca** Automation nodes
- CPU subcluster: **robot{1,2,3,4}.scinet.utoronto.ca**
- GPU subcluster: **trig-robot1.scinet.utoronto.ca**
Open OnDemand: [ondemand.scinet.utoronto.ca](https://ondemand.scinet.utoronto.ca/) (includes JupyterLab) Portal: [my.scinet.utoronto.ca](https://my.scinet.utoronto.ca/)

Trillium is a large parallel cluster built by Lenovo Canada and hosted by SciNet at the University of Toronto.

The [Trillium Quickstart](https://docs.alliancecan.ca/wiki/Trillium_Quickstart "Trillium Quickstart") has specific instructions for Trillium, where the user experience is similar to that on the other national clusters, but still slightly different.

Current users transitioning from Niagara are strongly encouraged to peruse the documentation on the [Transition from Niagara to Trillium](https://docs.alliancecan.ca/wiki/Transition_from_Niagara_to_Trillium "Transition from Niagara to Trillium").

## Storage

Parallel storage: 29 petabytes, NVMe SSD based storage from VAST Data.

## High-performance network

- Nvidia “NDR” Infiniband network
	- 400 Gbit/s network bandwidth for CPU nodes
		- 800 Gbit/s network bandwidth for GPU nodes
		- Fully non-blocking, meaning every node can talk to every other node at full bandwidth simultaneously.

## Node characteristics

| Login Node | nodes | cores | available memory | CPU | GPU |
| --- | --- | --- | --- | --- | --- |
| trillium.alliancecan.ca | 1224 | 192 | 749G or 767000M | 2 x AMD EPYC 9655 (Zen 5) @ 2.6 GHz, 384MB cache L3 |  |
| trillium‑ **gpu**.alliancecan.ca | 63 | 96 | 749G or 767000M | 1 x AMD EPYC 9654 (Zen 4) @ 2.4 GHz, 384MB cache L3 | 4 x NVidia H100 SXM (80 GB memory), connected via NVLink |

## Technical details

## Cooling and energy efficiency

Trillium is fully direct liquid cooled using warm water (35–40 °C input), resulting in:

- PUE below 1.03 (high energy efficiency)
- Use of closed-loop dry fluid coolers, avoiding evaporative towers and new water usage
- Heat reuse: Trillium supplies excess heat to nearby facilities to minimize climate impact

## Storage system

The VAST high-performance file system is comprised of a unified 29 PB NVMe-backed storage pool, with:

- 29 PB effective capacity (deduplicated via VAST)
- 16.7 PB raw flash capacity
- 714 GB/s read bandwidth, 275 GB/s write bandwidth
- 10 million read IOPS, 2 million write IOPS
- POSIX and S3 access protocols under a unified namespace
- 48 C-Boxes and 14 D-Boxes for data services

An additional 114 PB HPSS tape-based archive is available for nearline storage:

- Dual-copy archive across geographically separate libraries
- Used for both backup and archival purposes
- Backups are managed using Atempo backup software

## Site specifics

Do not assume that things work the same on Trillium as on the other clusters. While there is a large degree of conformity, Trillium was designed for large-scale computations and this has resulted in a few different design and policy decisions.

The specifics of Trillium are described only briefly below; please read the [Trillium Quickstart](https://docs.alliancecan.ca/wiki/Trillium_Quickstart "Trillium Quickstart") for details.

## Logging in

- Password access to the login nodes is disabled. You must use [SSH Keys](https://docs.alliancecan.ca/wiki/SSH_Keys "SSH Keys") and [MFA](https://docs.alliancecan.ca/wiki/MFA "MFA").
- There are separate login and robot nodes for CPU and GPU subclusters.

### SSH access setup (`cluster-login` + direct `ssh`)

`~/.ssh/config` has `Host trillium` (`HostName trillium.alliancecan.ca`) and `Host trillium-gpu`
(`HostName trillium-gpu.alliancecan.ca`), both `User yorguin`, inheriting the shared `Host *`
ControlMaster block — so `ssh -o BatchMode=yes trillium …`, `… trillium-gpu …`, and
`cluster-login trillium[-gpu]` work exactly like `fir`. (`~/.ssh/config` and `~/.ssh/known_hosts`
live outside this repo and are not versioned here.)

Host-key fingerprints were verified on 2026-08-12: `ssh-keyscan` of **both** hostnames returned
the **same** keys, matching `SSH host keys.md` in this repo (the Alliance wiki was unreachable to
automated fetches at the time — behind bot protection — so the repo's clipped copy was the
verification source):

- ED25519 `SHA256:ZdxQWOLHPQb11qPxHh2Vq+trSULZA1+rvTU6pePelSc`
- RSA `SHA256:7lMM6nG32IWndLfCZhrJ6a/jKcuuvvajS6XUiRclB74`

Only these fingerprint-verified keys were added to `~/.ssh/known_hosts` (required because
agent calls use `ssh -o BatchMode=yes`, which fails on an unverified host key).

## Internet access

- The internet cannot be reached from compute nodes.
- Interactive Apps on OnDemand, however, do have internet access.

## Home space

- You will have space for up to 100 GB or 1 million files in your `$HOME` directory.
- `$HOME` cannot be written to from compute jobs.
- Interactive Apps on OnDemand, however, do have write access to `HOME`.

## Project space

- You can find links to the project spaces to which you have access in the `$HOME/links` directory.
- Default accounts have access to a project space of 1 TB per group.
- It is not possible to request more project space on Trillium through RAS.
- `$PROJECT` cannot be written to from compute jobs.

## Scratch space

- Users have a nominal quota of 25TB, but are expected to clean up all unused data.
- There is no purging policy yet, but this is subject to change in the future.

## Nearline space

- The nearline storage on Trillium is not mounted on the nodes but needs to be accessed via jobs submitted to the [HPSS](https://docs.scinet.utoronto.ca/index.php/HPSS) SLURM partition, or via [Globus](https://docs.alliancecan.ca/wiki/Globus "Globus").

## Local disk space

- Trillium nodes have no local storage.
- For certain workflows, using the RAM disk can be a possibility. To reflect this, the `$SLURM_TMPDIR` environment variable points to a folder on the RAM disk.

## Access through Open OnDemand (OOD)

- Instead of JupyterHub, Trillium has [OpenOnDemand](https://docs.alliancecan.ca/wiki/Trillium_Open_OnDemand_Quickstart "Trillium Open OnDemand Quickstart"). This support a growing number of applications from your browser, such as JupyterLab, VS Code, RStudio, MATLAB, ParaView, the DDT debugger, as well as a

terminal and job submissions.

## Job scheduling

- The resources in the CPU subcluster are scheduled by whole 192-core node.
- The resources in the GPU subcluster are scheduled by whole GPU (no "MIG"), or by whole node.

## Gotchas learned (job submission)

Hard-won during the amica-benchmark iteration-ladder campaign (2026-08). These bit in sequence —
each one hid behind the previous — so a job can fail for several of these at once.

1. **Submit GPU jobs from the GPU login node.** `ssh -o BatchMode=yes trillium` lands on a *CPU* login node
   (`tri-login01`), which the scheduler blocks from requesting GPUs:
   `"GPU resources requested from a CPU login node; please submit from trig-login01."`
   Use the **`trillium-gpu`** alias (`trig-login01`) for anything with `--gpus-per-node`. Both share
   the same `/scratch`, so files/caches/venvs are visible from either — only the submit host differs.
2. **`--export=NONE` is forced** by a site `sbatch` wrapper (`/opt/slurm/bin/sbatch --export=NONE`).
   Your shell environment — including custom vars like `MANIFEST` — does **not** reach the job, and you
   can't override it with `--export=ALL` (the wrapper's flag wins). Pass values as **positional args**
   to the script (immune to env stripping) or set them *inside* the job script. `SLURM_*` vars survive.
3. **Whole-node scheduling — no `--mem` / `--cpus-per-task` / `--ntasks`.** These are rejected
   (`"--mem ... is not allowed nor necessary on Trillium; ... each job gets all the node's memory"`).
   Use only `--nodes` / `--gpus-per-node` / `--time`. A CPU-only job still gets a *whole node*, so don't
   fan a small task into a big job array (25 tasks = 25 whole nodes) — loop inside one job instead.
4. **QOS `normal` limits: MaxSubmit=500, MaxRunning=150, MaxTRES `gpu=100`.** A >500-element array is
   rejected with `QOSMaxSubmitJobPerUserLimit` — split into waves that each fit under 500 submitted.
   Also **`MaxArraySize=1001`** (vs 10000 on fir): array indices must be ≤ 1000.
5. **Read-only HOME on compute nodes.** Anything writing to `~/.cache` fails with
   `PermissionError: [Errno 13] ... /home/<user>/.cache/...`. Redirect caches to `/scratch`:
   `export XDG_CACHE_HOME=/scratch/$USER/.cache JAX_COMPILATION_CACHE_DIR=/scratch/$USER/.cache/jax MPLCONFIGDIR=/scratch/$USER/.cache/mpl`
   (the amica_python JAX backend honours `JAX_COMPILATION_CACHE_DIR` before falling back to `~/.cache`).
6. **Accounts — prefer `rrg-kjerbi` over `def-kjerbi`.** The RRG award (#5896, kif-392) carries **both**
   `fir-compute` CPU (715 core-years, ~1.6% used — huge headroom) **and** a Trillium `grillium-gpu`
   H100 GPU allocation. So `--account=rrg-kjerbi` is the right choice for *both* CPU and GPU here; use
   `def-kjerbi` only as a fallback. (Naming differs by cluster: fir uses suffixed `rrg-kjerbi_cpu` /
   `def-kjerbi_gpu`; Trillium uses the bare `rrg-kjerbi` / `def-kjerbi`.)
7. **Module env survives `--export=NONE`.** `source /cvmfs/.../config/profile/bash.sh` + `module load`
   inside the script works fine (the earlier failures were env/cache, not modules). For an mne-capable
   orchestrator, also `source <venv>/bin/activate` inside the job.
- For other scheduling specifics, please see the [Trillium Quickstart](https://docs.alliancecan.ca/wiki/Trillium_Quickstart "Trillium Quickstart").