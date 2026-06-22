#!/usr/bin/env bash
wget -q http://192.168.63.1:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin

echo "Чтение сообщений из очереди Direct..."
./rabbitmqadmin get -H 192.168.63.1 -u receiver_direct -p pass -V vhost_task1 \
queue=queue_direct count=50
