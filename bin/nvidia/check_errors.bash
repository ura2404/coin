#!/bin/bash

echo '----------------------------------------'
echo 'Check nvidia errors'

LOG=$ROOT/log/nvidia_err.log

#Errors
ERR1='Reboot the system to recover this GPU'

# purge log file
#find $ROOT/log -name 'nvidia_err.log' -mtime +10 -delete
TRUN=`cat $ROOT/conf/log.json | $JQ '.truncate' | $JQ '.err' | sed 's/\"//g'`
if [ -e "$ROOT/flg/tr_err.flg" ]
then
    rm -f $ROOT/flg/tr_err.flg
    tail $LOG -n $TRUN > $LOG'1'
    mv $LOG'1' $LOG
fi



#
N=`cat $ROOT/conf/nvidia.json | $JQ '.total' | sed 's/\"//g'`
COUNT=`$SMI --format=csv --query-gpu=index | sed '1d' | wc -l`

RET=`$SMI --format=csv --query-gpu=index`

E1=`echo $RET | grep "$ERR1"`

if [ -n "$E1" ]
then
    echo `date +%Y-%m-%d_%H:%M:%S` 'Reboot by error "'$E1'"' | tee -a $LOG
    sudo reboot
else
    if [ "$N" != "$COUNT" ]
    then
        echo `date +%Y-%m-%d_%H:%M:%S` 'Reboot by wrong GPU count ('$COUNT')' | tee -a $LOG
        nvidia-smi | tee -a $LOG
        sudo reboot
    else
        echo 'Errors not found' >> /dev/null
    fi
fi

