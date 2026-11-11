# Recommended tools

Which tool to reach for, and when to fall back. Cluster rules (login vs compute, quotas, internet per cluster) are in [AGENT.md](AGENT.md); this file only says which tool.

## Python environments: uv

**Default: [uv](https://docs.astral.sh/uv/).** Use it on the labs, the laptop and the Alliance clusters. Mila recommends it for its clusters, and this setup standardises on it (2026-11-11).

- Projects: `pyproject.toml` + `uv.lock`, `uv sync` to build `.venv`, `uv run <cmd>` to use it.
- One-off environments: `uv venv` then `uv pip install …`.
- Tools you want on `PATH`: `uv tool install <pkg>`.
- On a cluster:
  - Build inside an allocation, not on a login node (AGENT.md A.1, B.8).
  - Put the cache on scratch: `export UV_CACHE_DIR=/scratch/$USER/.cache/uv`.
  - On clusters whose compute nodes have no internet (Trillium; see AGENT.md B.8), fill the cache on the login node first, then sync inside the job.

**Fallback: Alliance's own route.** Alliance's docs teach `module load python` + `virtualenv --no-download` + `pip install --no-index` against their wheelhouse. Use it only when a package won't install or work through uv, typically one that's compiled against the cluster's modules. The wheelhouse can also hold you back with old versions (see the mne/scipy row in AGENT.md Part C).

When advising someone else (a person or another agent session), lead with uv. Mention the pip route only as that fallback.

## Multi-cluster sync and submit: cluv

**[cluv](https://mila-iqia.github.io/cluv/)** (Mila, `uv tool install cluster-uv`, command `cluv`): the preferred way to run **uv projects hosted on GitHub** on several clusters.

- `cluv init` / `cluv login` / `cluv sync`: configure the project, open SSH masters (Duo once per cluster), push code and run `uv sync` remotely, fetch results.
- `cluv submit <cluster> job.sh`: sync, then `sbatch`.
- `cluv submit first job.sh`: submit everywhere and keep whichever starts first.
- `cluv status`: idle/total GPUs by type, your jobs, and `$HOME`/`$SCRATCH` usage on every connected cluster. Useful on its own even when you submit with plain `sbatch`; it needs only a minimal `pyproject.toml` (AGENT.md B.9, #41).

Installed so far only on lab4 (0.1.7, 2026-11-05). cluv still needs live SSH masters on the host it runs from, so it can only reach clusters you've logged into there with `cluster-login` (Duo). Plain `sbatch` (AGENT.md B.9) stays the fallback for non-uv projects or a single cluster.
