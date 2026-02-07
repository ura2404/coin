#!/bin/bash

DSRC=$(dirname $(realpath $BASH_SOURCE))
source $DSRC/env.sh

export DEF=$1

bash $ROOT/bin/nvidia/check_temp.bash $DEF
