#!/bin/bash

export ROOT=`pwd`
export JQ=`which jq`
export SMI=`which nvidia-smi`

bash bin/nvidia/check_errors.bash
