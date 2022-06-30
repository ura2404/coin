#!/bin/bash

echo '----------------------------------------'
echo 'Check nvidia errors'

LOG=$ROOT/log/nvidia_err.log

#Errors
ERR1='Reboot the system to recover this GPU'


# purge log file
find $ROOT/log -name 'nvidia_err.log' -mtime +10 -delete

#
RET=`$SMI --format=csv --query-gpu=index`

E1=`echo $RET | grep "$ERR1"`

if [ -n "$E1" ]
then
    echo 'Make reboot by nvidia-smi errors'
    echo `date +%Y-%m-%d_%H:%M:%S` 'Reboot by error "$E1"' >> $LOG
    sudo reboot
else
    echo 'Errors not found' >> /dev/null
fi

