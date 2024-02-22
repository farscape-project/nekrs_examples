#!/bin/bash

ulimit -s unlimited

which nrsmpi | tee log.nrsversion

nekrs --setup yPlus.par 2>&1 | tee log.yPlus
nrsvis yPlus
