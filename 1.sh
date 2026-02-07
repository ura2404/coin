#!/bin/bash

if find flg/nvidia.flg -mmin +1 | grep -q .; then
    echo "Файл старше 1 минут"
else
    echo "Файл моложе 1 минут"
fi
! find flg/nvidia.flg -mmin +1 | grep -q . &&  echo "<<<" || echo ">>>"

ROOT=`pwd`

C=5
while [ $C -gt 0 ]
do
    (
            [ ! -f $ROOT/flg/reboot.flg ]              &&
            ! find flg/nvidia.flg -mmin +2 | grep -q .
    ) && sleep 1; echo "--$C"
    C=$((C-1))

done