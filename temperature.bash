#!/bin/bash

export ROOT=`pwd`
export SMI=`which nvidia-smi`
export JQ=`which jq`

export DEF=$1

bash bin/nvidia/check_temp.bash $DEF
