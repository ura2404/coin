#!/bin/bash

DSRC=$(dirname $(realpath $BASH_SOURCE))
# echo $DSRC

export ROOT=$DSRC
export JQ=`which jq`
export SCREEN=`which screen`
export SMI=`which nvidia-smi`
