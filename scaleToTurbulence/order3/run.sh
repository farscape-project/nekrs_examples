#!/bin/bash

cores=4

ulimit -s unlimited

which nrsmpi | tee log.nrsversion

nrsmpi pipe $cores 2>&1 | tee log.pipe_order$cores
nrsvis pipe
