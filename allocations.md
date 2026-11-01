# kjerbi lab — Alliance allocations (CCDB snapshot)

Copied from CCDB → *My Account → My Resources and Allocations* on **2026-10-01**. PI: Karim Jerbi (kif-392). Re-check CCDB for
current figures; RAC awards renew yearly (the current ones expire 2027-04-01).

## RAC — `rrg-kjerbi` (RAPI kif-392-ac)

| Resource | Allocation | Type | Expires | Slurm account |
|---|---|---|---|---|
| Fir | **715 core-years** (715 core-equivalents, 2859 GB total system memory) | CPU | 2027-04-01 | `rrg-kjerbi_cpu` |
| Fir | 50 TB project storage + 299 TB nearline | Storage | 2027-05-01 | — |
| Trillium | **150 RGU-years** (157.38 RGU-equivalent years, 2360.7 GB memory, 49.18 CPU cores) | GPU | 2027-04-01 | `rrg-kjerbi` |
| Trillium | 150 TB project storage | Storage | 2027-05-01 | — |

Conversions: 1 core-year = 8,760 core-hours, so 715 core-years ≈ **6.26M core-hours per allocation year** on fir. That is the target
*rate* the scheduler's fair share is tuned to: an average of ~715 cores in continuous use. It is not a hard cap. The award is shared
by the whole group, so ask the PI what share a project may use.

Fair share as seen from fir: `sshare -l -A rrg-kjerbi_cpu` shows RawShares 715000, against 104393 for `def-kjerbi_cpu`.

## Default (RAS) — `def-kjerbi` (RAPI kif-392-aa)

On Narval, Nibi, Rorqual, Fir and Trillium: **1 TB project storage each**, plus *opportunistic* CPU/GPU use at low priority, with no
guaranteed amount. Slurm accounts are `def-kjerbi` / `def-kjerbi_cpu` / `def-kjerbi_gpu` depending on the cluster.

## AI (PAICE) — `aip-kjerbi` (RAPI kif-392-ab)

GPU access on **TamIA**, **Vulcan** and **Killarney**, expiring 2030-04-01. CCDB shows no numeric allocation. See the per-cluster docs
in `compute-canada/`.

## `rrg-shahabkb` (RAPI khv-102-ab): left over from an inactive role, don't rely on it

CCDB (2026-11-01) lists the user's active role as **yup-345-02** (Master's, UdeM DIRO, sponsored by Karim Jerbi, kif-392-01), which
carries def-kjerbi, rrg-kjerbi and aip-kjerbi. The inactive undergraduate role **yup-345-01** (Psychology, deactivated 2024) still lists
membership in `rrg-shahabkb` (FT #3605 [RRG 2026], "An optimization approach to multi-species modeling of visual systems", active,
3 allocations). Narval's Slurm still shows `rrg-shahabkb_cpu` / `rrg-shahabkb_gpu` for user yorguin (2026-11-01). Since it hangs off an
inactive role, it may or may not accept jobs, and it isn't the user's group's allocation: don't use it unless the user says so.

## Narval notes (2026-11-01)

- `/project/def-kjerbi` is at 948 of 1000 GB: put working data in `/scratch/$USER`.
- Narval nodes are AMD Zen2: no AVX-512, so don't build with `-march` flags from fir/trillium.
- In use by: gica (`/scratch/yorguin/gica`, see `fleet/projects.yaml`).
