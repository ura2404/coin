#!/bin/bash

# Установить PL
#
# Параметры
# - $1 - номер GPU
# - $2 - PL | 'def' - default PL

SMI=`which nvidia-smi`

S=`$SMI -i $1 --format=csv,noheader --query-gpu=power.limit,power.min_limit,power.default_limit,power.max_limit`
PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`		# текущий PL
PMIN=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# минимальный PL
PDEF=`echo $S | cut -d ',' -f3 | cut -d ' ' -f2 | cut -d '.' -f1`		# PL по умолчанию
PMAX=`echo $S | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1`		# макимальный PL

NP=$2
[ "$2" == "def" ] &&  NP=$PDEF
[ "$2" == "min" ] &&  NP=$PMIN
[ "$2" == "max" ] &&  NP=$PMAX


#if [ "$2" == "def" ]
#then
#    S=`$SMI -i $1 --format=csv,noheader --query-gpu=power.limit,power.min_limit,power.default_limit,power.max_limit`
#    PL=`echo $S | cut -d ',' -f1 | cut -d ' ' -f1 | cut -d '.' -f1`		# текущий PL
#    PMIN=`echo $S | cut -d ',' -f2 | cut -d ' ' -f2 | cut -d '.' -f1`		# минимальный PL
#    PDEF=`echo $S | cut -d ',' -f3 | cut -d ' ' -f2 | cut -d '.' -f1`		# PL по умолчанию
#    PMAX=`echo $S | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1`		# макимальный PL
#    NP=$PDEF

#    echo $S
#    echo 'PL='$PL
#    echo 'PDEF='$PDEF
#    echo 'PMIN='$PMIN
#    echo 'PMAX='$PMAX

#else
#    NP=$2
#fi

sudo $SMI -i $1 -pl $NP
