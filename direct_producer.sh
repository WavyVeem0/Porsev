#!/usr/bin/env bash
wget -q http://192.168.63.1:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin

# Генерация случайного количества сообщений с фамилией
I=$(shuf -i 10-30 -n 1)
echo "Отправка $I сообщений..."

for i in $(seq 1 $I); do
    sleep $(shuf -i 0-1 -n 1) # Снизил задержку для быстроты теста
    TEXT="$(tr -dc A-Za-z0-9 </dev/urandom | head -c $(shuf -i 10-30 -n 1)) PROSHUNIN"
    echo "Отправлено: $TEXT"
    
    ./rabbitmqadmin publish -H 192.168.63.1 -u sender_direct -p pass -V vhost_task1 \
    exchange=ex_direct routing_key=key_direct payload="$TEXT" > /dev/null
done
