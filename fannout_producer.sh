#!/usr/bin/env bash
wget -q http://192.168.63.2:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin

I=$(shuf -i 10-30 -n 1)
echo "Отправка $I сообщений в Fanout Exchange..."

for i in $(seq 1 $I); do
    sleep $(shuf -i 0-1 -n 1)
    TEXT="$(tr -dc A-Za-z0-9 </dev/urandom | head -c $(shuf -i 10-30 -n 1)) PROSHUNIN_FANOUT"
    echo "Отправлено: $TEXT"
    
    # Для Fanout routing_key игнорируется, можно оставить пустым
    ./rabbitmqadmin publish -H 192.168.63.2 -u sender_fanout -p pass -V vhost_task2 \
    exchange=ex_fanout routing_key="" payload="$TEXT" > /dev/null
done
