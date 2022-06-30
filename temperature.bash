#!/bin/bash

export ROOT=`pwd`
export SMI=`which nvidia-smi`

bash bin/nvidia/check_temp.bash
