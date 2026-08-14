# TODO

## Optional: restore the "master down" phone alert (ntfy) without cluster-run

**Context.** `cluster-run` was deprecated (commit `009b892`) — agents now call
`ssh -o BatchMode=yes <host> <cmd>` directly. The old wrapper had a side feature that's now
gone: on master-down it POSTed a "master is DOWN — needs an MFA refresh" message to
[ntfy](https://ntfy.sh) so the phone buzzed and you knew to run `cluster-login`.

**Task.** If we want that automatic buzz back, add a tiny `bin/` helper (e.g. `cluster-ssh`)
that wraps the direct call and pings ntfy only on the fail-fast exit — without reintroducing
the exit-42 / master-check semantics that confused agents:

```bash
#!/usr/bin/env bash
# ssh -o BatchMode=yes <host> <cmd...>; on Permission-denied (master down) ping ntfy.
set -euo pipefail
ssh -o BatchMode=yes "$@" && exit 0
rc=$?
[ -n "${NTFY_TOPIC:-}" ] && curl -s -d "cluster master down — run cluster-login" \
  "https://ntfy.sh/${NTFY_TOPIC}" >/dev/null 2>&1 || true
exit "$rc"
```

**Decide first:** is the agent surfacing the `Permission denied` failure (Remote Control /
its own output) already enough, or do we want the out-of-band phone push too? If the latter,
build the wrapper, document it in `mobile-access.md` ("Optional: get pinged instead of
polling"), and point agents at it in rule A.6.

**Alternative (no new script):** have the agent itself curl ntfy when it detects the failure,
via its project/`CLAUDE.md` rules. Keeps `bin/` to just `cluster-login`.
