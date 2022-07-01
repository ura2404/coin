#!/bin/bash

export ROOT=`pwd`
export SMI=`which nvidia-smi`
export JQ=`which jq`

bash bin/nvidia/check_temp.bash
