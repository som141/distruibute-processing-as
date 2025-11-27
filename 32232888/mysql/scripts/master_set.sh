#!/bin/bash
# =======================
# MySQL MASTER SETUP SCRIPT
# ✹ Usage: sudo ./master_set.sh
# =======================

set -e

echo "Starting MySQL Master Setup..."
apt update -y
apt install mysql-server -y

echo "Configuring MySQL for Master..."
CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"

sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" $CONF

grep -q "server-id" $CONF || cat <<EOF >> $CONF
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = testdb
EOF

systemctl restart mysql

mysql -uroot -e "CREATE DATABASE IF NOT EXISTS testdb;"

mysql -uroot <<EOF
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
EOF

mysql -uroot <<EOF
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
EOF
