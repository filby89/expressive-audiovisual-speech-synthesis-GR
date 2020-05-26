#!/bin/bash -e

## Generic script for submitting any Theano job to GPU
# usage: submit.sh [scriptname.py script_arguments ... ]

src_dir=$(dirname $1)

# Source install-related environment variables
source ${src_dir}/setup_env.sh

echo "Running on GPU ..."
THEANO_FLAGS="mode=FAST_RUN,device=cuda$gpu_id,"$MERLIN_THEANO_FLAGS
export THEANO_FLAGS

python $@
