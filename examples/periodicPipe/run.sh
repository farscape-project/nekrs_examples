#!/bin/bash

ulimit -s unlimited

which nrsmpi | tee log.nrsversion

nekrs --setup pipe.par 2>&1 | tee log.periodicPipe
nrsvis pipe
