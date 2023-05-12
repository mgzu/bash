#!/bin/bash

# setting
## password
ROOT_PWD=''
USE_RANDOM_PWD=false
RANDOM_ROOT_PWD=`openssl rand -base64 16`
## store directory
STORE_DIR=''
TEMP_DIR='~/.install_mysql_temp'

# install mysql
if [ -z "$STORE_DIR" ]; then
  mkdir -p $STORE_DIR
  cd $STORE_DIR
else
  mkdir -p $TEMP_DIR
  cd $TEMP_DIR
if

# get and install mysql rpm repository
wget https://repo.mysql.com//mysql80-community-release-el7-7.noarch.rpm
yum -y install mysql80-community-release-el7-7.noarch.rpm
# install mysql
yum -y install mysql-common mysql-libs mysql-libs-compat mysql mysql-server

# variable
DEFAULT_ROOT_PWD=`grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}'`

# set up root password
if [ -z "$ROOT_PWD" ]; then
  sh -c "mysql -uroot -p$DEFAULT_ROOT_PWD << \EOF
    ALTER user 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD'
  EOF"
  echo "root password is $ROOT_PWD"
else
  echo "root password is $DEFAULT_ROOT_PWD"
fi
