#!/bin/bash
# ============================
# MySQL SLAVE SETUP SCRIPT
# 💡 Usage example:
# sudo MASTER_IP=192.168.0.10 MASTER_LOG_FILE=mysql-bin.000001 MASTER_LOG_POS=123 ./slave_set.sh
# ============================

set -e

apt update -y
apt install -y mysql-server

CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"

sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" $CONF

LAST_OCTET=$(hostname -I | awk '{print $1}' | awk -F. '{print $4}')
grep -q "server-id" $CONF || cat <<EOF >> $CONF


server-id = $LAST_OCTET
relay_log = /var/log/mysql/mysql-relay-bin.log
read_only = 1
EOF


systemctl restart mysql


mysql -uroot <<EOF
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='$MASTER_IP',
  MASTER_USER='repl',
  MASTER_PASSWORD='repl_password',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G
EOF
