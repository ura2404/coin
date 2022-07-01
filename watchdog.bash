#!/bin/bash

export ROOT=`pwd`
export JQ=`which jq`

. $ROOT/bin/watchdog/tishric

[ "$1" == "init" ] && watch_init && exit

watch