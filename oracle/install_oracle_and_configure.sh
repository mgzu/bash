#!/bin/bash

# setting
ORACLE_BASE=/opt/oracle
ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
ORACLE_SID=ORCLCDB
LISTENER_PORT=1521
CONFIG_FILE="/etc/init.d/oracledb_${ORACLE_SID}-19c"

CHARSET="ZHS16GBK"

CURRENT_TIME=`date "+%Y%m%d%H%M%S"`
BACK_FILE="${CONFIG_FILE}${CURRENT_TIME}"


# backup config file
cp ${CONFIG_FILE} ${BACK_FILE}
echo "backup ${BACK_FILE}"

# change oracle 19c default charsest to GBK
echo "default charsest ${CHARSET}"
sed -i "s/CHARSET=AL32UTF8/CHARSET=${CHARSET}/g" ${CONFIG_FILE}

# configure
echo create database
${CONFIG_FILE} configure
CONFIGURE_STATUS=$?
if [[ ${CONFIGURE_STATUS} > 0 ]]; then
  exit
fi
echo "database created"

# set user env
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc
echo "export ORACLE_SID=$ORACLE_SID" >> /home/oracle/.bashrc
echo "export PATH=\$PATH:\$ORACLE_HOME/bin" >> /home/oracle/.bashrc

# pluggable database trigger
su -l oracle -c "sqlplus / as sysdba << EOF
  CREATE TRIGGER open_all_pdbs
  AFTER STARTUP ON DATABASE
  BEGIN
  EXECUTE IMMEDIATE 'alter pluggable database all open';
  END open_all_pdbs;
EOF"
echo "open_all_pdbs trigger created"

# pdb name
ORACLE_PDB="`ls -dl $ORACLE_BASE/oradata/$ORACLE_SID/*/ | grep -v pdbseed | awk '{print $9}' | cut -d/ -f6`"

# random password
ORACLE_PWD=`openssl rand -base64 8`
su -l oracle -c "sqlplus / as sysdba << EOF
  ALTER PLUGGABLE DATABASE ALL OPEN;
  ALTER USER SYS IDENTIFIED BY "$ORACLE_PWD";
  ALTER USER SYSTEM IDENTIFIED BY "$ORACLE_PWD";
  ALTER SESSION SET CONTAINER=$ORACLE_PDB;
  ALTER USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD";
  exit;
EOF"

# stop oracle listener
su -l oracle -c "lsnrctl stop"

su -l oracle -c "echo 'LISTENER =
DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
' > $ORACLE_HOME/network/admin/listener.ora"

su -l oracle -c "echo '$ORACLE_PDB=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = $LISTENER_PORT))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)' >> $ORACLE_HOME/network/admin/tnsnames.ora"

# start oracle listener
su -l oracle -c "lsnrctl start"
