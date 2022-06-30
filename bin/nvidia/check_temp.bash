#!/bin/bash

echo '----------------------------------------'
echo 'Check nvidia temperature'

LOG=$ROOT/log/nvidia_temp.log

# need temp
TN=66

# запас до мах power limit
DMAX=2

# --- --- --- --- ---
function def(){
    N=${1}
    T=${2}
    #echo $N 'def'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.default_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`
    PDEF=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`
    #echo $PL---$PDEF

    [ $PL -ne $PDEF ] && sudo $SMI -i $N -pl $PDEF &&  echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(*)def\t\t' $NP 'W' >> $LOG
}

# --- --- --- --- ---
function up(){
    N=${1}
    T=${2}
    echo $N 'up'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.default_limit,power.max_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`
    PDEF=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`
    PMAX=`echo $S | cut -d ',' -f3 | cut -d ' ' -f2 | cut -d '.' -f1`

    NP=$(( PL+1 ))

    [ $NP -gt $PDEF ] && return

    [ $NP -lt $(( PMAX - DMAX )) ] && sudo $SMI -i $N -pl $NP && echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(^)up\t\t'$PL 'W -> '$NP 'W' >> $LOG
}

# --- --- --- --- ---
function down(){
    N=${1}
    T=${2}
    echo $N 'down'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.min_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`
    PMIN=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`

    NP=$(( PL-1 ))

    [ $PL -gt $(( PMIN +0 )) ] && sudo $SMI -i $N -pl $NP &&  echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(v)down\t\t'$PL 'W -> '$NP 'W' >> $LOG
}

# --- --- --- --- ---
# --- --- --- --- ---
# --- --- --- --- ---

# purge log file
find $ROOT/log -name 'nvidia_temp.log' -mtime +1 -delete

# работать, только если запущен майнер
PID=`ps aux | grep -e 'SCREEN' -e 'COIN' | grep -v grep`
#echo 'PID='$PID

[ -z "$PID" ] && exit

# перебираем gpu
$SMI dmon -c 1 | grep -v '#' | while read a; do
    N=`echo $a | awk '{ print $1 }'`
    T=`echo $a | awk '{ print $3 }'`

    #echo '-------------------'
    #echo 'N (number)='$N
    #echo 'T (temperature)='$T

    # example: 77.00 W, 90.00 W, 66.00 W, 113.00 W
    # S=`$NVSMI -i $N --format=csv,noheader --query-gpu=power.limit,power.default_limit,power.min_limit,power.max_limit`
    # PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`
    # PDEF=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`
    # PMIN=`echo $S | cut -d ',' -f3 | cut -d ' ' -f2 | cut -d '.' -f1`
    # PMAX=`echo $S | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1`
    #echo $PL-$PDEF-$PMIN-$PMAX

    # def $N

    [ $T -le $(( TN - 1 )) ] && up $N $T
    [ $T -ge $(( TN + 1 )) ] && down $N $T
done
