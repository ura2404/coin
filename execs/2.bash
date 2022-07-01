EMAIL=u2rostov@gmail.com
COIN=sero
WALLET=2CdAhAar9nWECZqebKNS9b9JJYAoSbFaywocy8TaogAuYYPghidYWQ2J9FBcpXrrsD6bN14nS7dCvYLCPYV9XizVdEd1zpe55cZFLHzRYxmxkurjqhBufbt6hfZRjzWH7gCx
IP=0.0.0.0
PORT=4067
DEVICES=0,1,2,3

./t-rex -a progpow --coin sero -o stratum+tcp://pool2.sero.cash:8808 -u $WALLET -p x -w $NAME --api-bind-http $IP:$PORT -d $DEVICES
