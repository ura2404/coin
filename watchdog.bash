#!/bin/bash

DSRC=$(dirname $(realpath $BASH_SOURCE))
source $DSRC/env.sh

source $ROOT/bin/watchdog/tishric
[ "$1" == "init" ] && watch_init && exit
watch
