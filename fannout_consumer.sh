#!/usr/bin/env bash
wget -q http://192.168.63.1:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin

echo "=== Чтение из Очереди 1 (Пользователь 1) ==="
./rabbitmqadmin get -H 192.168.63.1 -u receiver_fanout1 -p pass -V vhost_task2 \
queue=queue_fanout_1 count=5

echo "=== Чтение из Очереди 2 (Пользователь 2) ==="
./rabbitmqadmin get -H 192.168.63.1 -u receiver_fanout2 -p pass -V vhost_task2 \
queue=queue_fanout_2 count=5
