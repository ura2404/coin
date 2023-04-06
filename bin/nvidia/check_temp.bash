#!/bin/bash

echo '----------------------------------------'
echo 'Check nvidia temperature'

# --- --- --- --- ---
# настройки
LOG=$ROOT/log/nvidia_temp.log	# лог-файл
TEMP=$ROOT/conf/temp.json	# температурные настройки
LAST=$ROOT/tmp			# папка сохранения последнего PL
DMAX=1				# запас до мах power limit
UPLIM=`cat $TEMP | $JQ '.max'`	# естанавливать PL сверх defaut
echo $UPLIM


# --- --- --- --- ---
# работать, только если запущен майнер
PID=`ps aux | grep -e 'SCREEN' -e 'COIN' | grep -v grep`
#echo 'PID='$PID
[ -z "$PID" ] && exit

# --- --- --- --- ---
# получить температуру по умолчанию
TALL=`cat $TEMP | $JQ '.all'`
echo 'TALL='$TALL

# --- --- --- --- ---
# purge log file
#find $ROOT/log -name 'nvidia_temp.log' -mtime +1 -delete
TRUN=`cat $ROOT/conf/log.json | $JQ '.truncate' | $JQ '.temp' | sed 's/\"//g'`
if [ -e "$ROOT/flg/tr_temp.flg" ]
then
    rm -f $ROOT/flg/tr_temp.flg
    tail $LOG -n $TRUN > $LOG'1'
    mv $LOG'1' $LOG
fi


# --- --- --- --- ---
function def(){
    N=${1}	# номер GPU
    T=${2}	# текущая температура
    echo 'make def'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.default_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`		# текущий PL
    PDEF=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# PL по умолчанию
    #echo $PL---$PDEF

    [ $PL -ne $PDEF ] && sudo $SMI -i $N -pl $PDEF &&  echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(*)def\t\t' $NP 'W' >> $LOG
}

# --- --- --- --- ---
function up(){
    N=${1}	# номер GPU
    T=${2}	# текущая температура
    echo 'make up'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.default_limit,power.max_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`		# текущий PL
    PDEF=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# PL по умолчанию
    PMAX=`echo $S | cut -d ',' -f3 | cut -d ' ' -f2 | cut -d '.' -f1`		# макимальный PL

    # устанавливаемый PL
    NP=$(( PL+1 ))

    # если температура больше температуры по умолчанию, то ничего не делать
    if [ "$UPLIM" != "true" ]; then
    [ $NP -gt $PDEF ] && echo 'pl=MAX do nothing' && return
    fi

    # если температура больше, чем максимальный минус запас (см. выше), то ничего не делать
    [ $NP -gt $(( PMAX - DMAX )) ] && echo 'pl > MAX-DMAX do nothing' && return

    # установить PL
    sudo $SMI -i $N -pl $NP && echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(^)up\t\t'$PL 'W -> '$NP 'W' >> $LOG

    # сохранить PL
    echo $NP > $LAST/pl_$N
}

# --- --- --- --- ---
function down(){
    N=${1}	# номер GPU
    T=${2}	# текущая температура
    echo 'make down'

    S=`$SMI -i $N --format=csv,noheader --query-gpu=power.limit,power.min_limit`
    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`		# текущий PL
    PMIN=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# минимальный PL

    # устанавливаемый PL
    NP=$(( PL-1 ))

    # если желаемая температура меньше ,чем минимальный, то ничего не делать
    [ $NP -lt $(( PMIN + 1 )) ] && echo "pl < MIN($PMIN) do nothing" && return

    # установить PL
    sudo $SMI -i $N -pl $NP &&  echo -e `date +%Y-%m-%d_%H:%M:%S`'\tNo.'$N'\t'$T'\xc2\xb0\t(v)down\t\t'$PL 'W -> '$NP 'W' >> $LOG

    # сохранить PL
    echo $NP > $LAST/pl_$N
}

# --- --- --- --- --- --- --- --- ---
# --- --- --- --- --- --- --- --- ---
# --- --- --- --- --- --- --- --- ---
# перебираем gpu
$SMI dmon -c 1 | grep -v '#' | while read a; do
    N=`echo $a | awk '{ print $1 }'`	# номер GPU
    T=`echo $a | awk '{ print $3 }'`	# текущая температура GPU

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

    #TN=`cat $TEMP | $JQ 'map(select(.))|.['$N']'`
    TN=`cat $TEMP | $JQ '.t'$N`				# желаемая температура (из конфига)
    [ $TN == 'null' ] && TN=$TALL

    echo '--------'
    echo "N=$N"
    echo "TC=$T"
    echo 'TN='$TN

    #cat raw.json|jq -r -c 'map(select(.a=="x"))|.[1]'
    #( map(select(.a == "x")) | nth(1) )

    if [ -z $1 ] 
    then
        [ $T -le $(( TN - 1 )) ] && up $N $T
        [ $T -ge $(( TN + 1 )) ] && down $N $T
    else
        def $N $T
    fi
done
