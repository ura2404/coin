#!/bin/bash

export ROOT=`pwd`
export JQ=`which jq`
export SCREEN=`which screen`

. $ROOT/bin/lib

#echo $ROOT >> $ROOT/log/log

cat $ROOT/conf/fly.json | $JQ '.[] | tostring' | sed 's/^\"//;s/\"$//' | make_exec
