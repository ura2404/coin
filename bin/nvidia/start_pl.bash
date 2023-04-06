#!/bin/bash

echo '----------------------------------------'
echo 'Set PL after reboot'

# --- --- --- --- ---
# настройки
LAST=$ROOT/tmp			# папка сохранения последнего PL

# --- --- --- --- --- --- --- --- ---
# --- --- --- --- --- --- --- --- ---
# --- --- --- --- --- --- --- --- ---
# перебираем gpu
$SMI dmon -c 1 | grep -v '#' | while read a; do
    N=`echo $a | awk '{ print $1 }'`	# номер GPU
    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.min_limit`
    PMIN=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# минимальный PL

    echo '--------'
    echo "N=$N"

    FILE=$LAST/pl_$N
    echo $PMIN
    [ -f $FILE ] && sudo $SMI -i $N -pl `cat $FILE` || sudo $SMI -i $N -pl $(( PMIN + 1 ))
done
