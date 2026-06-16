#!/bin/bash
rm -f /scratch/yorguin/test_compress/dest/derivatives_yorguin.tar
export SCRATCH_BASE_OVERRIDE=/scratch/yorguin/test_compress/scratch
export DEST_BASE_OVERRIDE=/scratch/yorguin/test_compress/dest
bash "$(dirname "$0")/compress.sh"
