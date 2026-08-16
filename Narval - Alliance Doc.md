---
title: "Narval - Alliance Doc"
source: "https://docs.alliancecan.ca/wiki/Narval/en"
author:
published:
created: 2026-08-16
description:
tags:
  - "clippings"
---
## Narval

Availability: since October 2021 Login node: **narval.alliancecan.ca** Globus collection: **[Compute Canada - Narval](https://app.globus.org/file-manager?origin_id=a1713da6-098f-40e6-b3aa-034efe8b6e5b)** Data transfer node (rsync, scp, sftp,...): **narval.alliancecan.ca** Portal: [https://portail.narval.calculquebec.ca/](https://portail.narval.calculquebec.ca/)

Narval is a general purpose cluster designed for a variety of workloads. Built by Dell Canada and CDW Canada it is located at the [École de technologie supérieure](https://www.etsmtl.ca/en/home) in Montreal. The cluster is named in honour of the [narwhal](https://en.wikipedia.org/wiki/Narwhal), a species of whale which has occasionally been observed in the Gulf of St. Lawrence.

## Site-specific policies

By policy, Narval's compute nodes cannot access the internet. If you need an exception to this rule, contact [technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support") explaining what you need and why.

Crontab is not offered on Narval.

Each job on Narval should have a duration of at least one hour (five minutes for test jobs) and you cannot have more than 1000 jobs, running or queued, at any given moment. The maximum duration for a job on Narval is 7 days (168 hours).

## Storage

| HOME   Lustre filesystem, 64 TB of space | - Location of home directories, each of which has a small fixed quota. - You should use the `project` space for larger storage needs. - Small per user [quota](https://docs.alliancecan.ca/wiki/Storage_and_file_management#Filesystem_quotas_and_policies "Storage and file management"). - There is a daily backup of the home directories. |
| --- | --- |
| SCRATCH   Lustre filesystem, 5.7 PB of space | - Large space for storing temporary files during computations. - No backup system in place. - Large [quota](https://docs.alliancecan.ca/wiki/Storage_and_file_management#Filesystem_quotas_and_policies "Storage and file management") per user. - There is an [automated purge](https://docs.alliancecan.ca/wiki/Scratch_purging_policy "Scratch purging policy") of older files in this space. |
| PROJECT   Lustre filesystem, 35 PB of space | - This space is designed for sharing data among the members of a research group and for storing large amounts of data. - Large and adjustable per group [quota](https://docs.alliancecan.ca/wiki/Storage_and_file_management/fr#Quotas_et_politiques "Storage and file management/fr"). - There is a daily backup of the project space. |

For transferring data via [Globus](https://docs.alliancecan.ca/wiki/Globus "Globus"), you should use the endpoint specified at the top of this page, while for tools like [rsync](https://docs.alliancecan.ca/wiki/Transferring_data#Rsync "Transferring data") and [scp](https://docs.alliancecan.ca/wiki/Transferring_data#SCP "Transferring data") you can use a login node.

## High-performance interconnect

The [InfiniBand](https://en.wikipedia.org/wiki/InfiniBand) [Mellanox HDR](https://www.nvidia.com/en-us/networking/infiniband/qm8700/) network links together all of the nodes of the cluster. Each hub of 40 HDR ports (200 Gb/s) can connect up to 66 nodes with HDR100 (100 Gb/s) with 33 HDR links divided in two (2) by special cables. The seven (7) remaining HDR links allow the hub to be connected to a rack containing the seven (7) central HDR InfiniBand hubs. The islands of nodes are therefore connected by a maximum blocking factor of 33:7 (4.7:1). In contrast, the storage servers are connected by a much lower blocking factor in order to maximize the performance.

In practice the Narval racks contain islands of 48 or 56 regular CPU nodes. It is therefore possible to run parallel jobs using up to 3584 cores with a non-blocking network. For larger jobs or ones which are distributed in a fragmented manner across the network, the blocking factor is 4.7:1. The interconnect remains a high-performance one nonetheless.

## Node characteristics

<table><thead><tr><th>nodes</th><th>cores</th><th>available memory</th><th>CPU</th><th>storage</th><th>GPU</th></tr></thead><tbody><tr><td>1145</td><td rowspan="3">64</td><td>250G or 256000M</td><td rowspan="2">2 x <a href="https://www.amd.com/en/support/downloads/drivers.html/processors/epyc/epyc-7002-series/amd-epyc-7532.html">AMD EPYC 7532 (Zen 2)</a> @ 2.40 GHz, 256M cache L3</td><td rowspan="3">1 x 960G SSD</td><td rowspan="3"></td></tr><tr><td>33</td><td>2009G or 2057500M</td></tr><tr><td>3</td><td>4000G or 4096000M</td><td>2 x <a href="https://www.amd.com/en/support/downloads/drivers.html/processors/epyc/epyc-7002-series/amd-epyc-7502.html">AMD EPYC 7502 (Zen 2)</a> @ 2.50 GHz, 128M cache L3</td></tr><tr><td>159</td><td>48</td><td>498G or 510000M</td><td>2 x <a href="https://www.amd.com/en/support/downloads/drivers.html/processors/epyc/epyc-7003-series/amd-epyc-7413.html">AMD EPYC 7413 (Zen 3)</a> @ 2.65 GHz, 128M cache L3</td><td>1 x SSD of 3.84 TB</td><td>4 x NVidia A100SXM4 (40 GB memory), connected via NVLink</td></tr></tbody></table>

### AMD processors

#### Supported instructions sets

Narval is equipped with 2nd and 3rd generation AMD EPYC processors which support the [AVX2 instruction set](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions#Advanced_Vector_Extensions_2).

Narval does not however support the [AVX512](https://en.wikipedia.org/wiki/AVX-512) instruction set, in contrast to the nodes of more recent clusters.

#### Intel compilers

Intel compilers can compile applications for Narval's AMD processors with AVX2 and earlier instruction sets. Use the \-march=core-avx2 option to produce executables which are compatible with both Intel and AMD processors.

However, if you have compiled a program on a system which uses Intel processors and you have used one or more options like \-xXXXX, such as \-xCORE-AVX2, the compiled program will not work on Narval because the Intel compilers add additional instructions in order to verify that processor used is an Intel product. On Narval, the options \-xHOST and \-march=native are equivalent to \-march=pentium (the old 1993 Pentium) and should **not** be used.

#### Software environments

[StdEnv/2023](https://docs.alliancecan.ca/wiki/Standard_software_environments "Standard software environments") is the standard software environment on Narval; previous versions (2016 and 2018) have been blocked intentionally. If you need an application only available with an older standard environment, please write to [Technical support](https://docs.alliancecan.ca/wiki/Technical_support "Technical support").

#### BLAS and LAPACK libraries

The Intel MKL library works with AMD processors, although not in an optimal way. We now favour the use of the FlexiBLAS library. For more details, please consult the page on [BLAS and LAPACK](https://docs.alliancecan.ca/wiki/BLAS_and_LAPACK "BLAS and LAPACK").

### GPU instances

To request one or more full A100 GPUs, you need to use one of the following Slurm options:

- **One A100-40gb**: `--gpus=a100:1`
- **Multiple A100-40gb** per node:
	- `--gpus-per-node=a100:2`
		- `--gpus-per-node=a100:3`
		- `--gpus-per-node=a100:4`
- **For multiple full A100 GPUs** spread anywhere: `--gpus=a100:n` (replace `n` with the number of GPUs you want)

Several GPU nodes are configured with [Multi-Instance GPU technology](https://docs.alliancecan.ca/wiki/Multi-Instance_GPU "Multi-Instance GPU"). Four sizes are available:

- **1g.5gb**: 1/8 compute capacity, GPU memory 5 GB
- **2g.10gb**: 2/8 compute capacity, GPU memory 10 GB
- **3g.20gb**: 3/8 compute capacity, GPU memory 20 GB

To request **one and only one** GPU instance for your compute job, options are:

- **1g.5gb**: `--gpus=a100_1g.5gb:1`
- **2g.10gb**: `--gpus=a100_2g.10gb:1`
- **3g.20gb**: `--gpus=a100_3g.20gb:1`

The maximum recommended number of **CPU cores and system memory** per GPU instance is listed in [this table](https://docs.alliancecan.ca/wiki/Allocations_and_compute_scheduling#Ratios_in_bundles "Allocations and compute scheduling").

## Monitoring jobs

From the [Narval portal](https://portail.narval.calculquebec.ca/), you can monitor your jobs using CPUs and GPUs **in real time** or examine jobs that have run in the past. This can help you to optimize resource usage and shorten wait time in the queue.

You can monitor your usage of

- compute nodes,
- memory,
- GPU.

It is important that you use the allocated resources and to correct your requests when compute resources are less used or not used at all. For example, if you request 4 cores (CPUs) but use only one, you should adjust the script file accordingly.