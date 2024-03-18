#!/bin/bash

ulimit -s unlimited

which nrsmpi | tee log.nrsversion

nekrs --setup laminarPipe.par 2>&1 | tee log.laminarPipe
nrsvis laminarPipe
