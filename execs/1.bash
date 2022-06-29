#!/bin/bash

cd /home/coin/coin.new/miners/nanominer-linux-3.5.2-cuda11

INDEX=1
INI=/home/coin/coin.new/execs/1.ini
NAME=coin2
EMAIL=u2rostov@gmail.com
COIN=rvn
WALLET=REH4AAhHSQidXddxv1JcCxVLjnsCdCdb4v
IP=0.0.0.0
PORT=3335
DEVICES=2,3

echo 'wallet = '$WALLET > $INI
echo 'coin = '$COIN >> $INI
echo 'rigName = '$NAME >> $INI
echo 'email = '$EMAIL >> $INI
echo 'devices = '$DEVICES >> $INI
echo 'mport = '$PORT >> $INI
echo 'noLog = true' >> $INI
./nanominer $INI
