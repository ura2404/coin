#!/bin/bash

DSRC=$(dirname $(realpath $BASH_SOURCE))
source $DSRC/env.sh

. $ROOT/bin/lib

cat $ROOT/conf/fly.json | $JQ '.[] | tostring' | sed 's/^\"//;s/\"$//' | make_exec
