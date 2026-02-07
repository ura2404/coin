#!/bin/bash

DSRC=$(dirname $(realpath $BASH_SOURCE))
source $DSRC/env.sh

bash $ROOT/bin/nvidia/start_pl.bash
