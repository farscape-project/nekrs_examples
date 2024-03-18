#!/bin/bash

source ~/.nekrs_23-0_profile

export NEKRS_KERNEL_DIR=$NEKRS_HOME/kernels

cores=4

ulimit -s unlimited

which nrsmpi | tee log.nrsversion

nrsmpi pipe $cores 2>&1 | tee log.pipe
nrsvis pipe
