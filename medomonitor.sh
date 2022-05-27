#!/bin/bash
IP_271=
PORT_271=
DB_271_USER=
DB_271_PASS=
DB_271_NAME=
home=/u01/CM/Error
#Путь до WildflyHome например /opt/wildfly
WFHOME=/u01/CM/wildfly

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_271 -p $PORT_271 -U $DB_271_USER -W $DB_271_PASS -d $DB_271_NAME -c "SELECT active from schedule WHERE NAME = 'MEDOProcessingScenario'" |grep -v active > $home/tmp/medo.txt
c=`cat $home/tmp/medo.txt`
v=1

if [ "$c" -ne "$v" ]
then
  echo "Агент не работает MEDOProcessingScenario"
else
  echo  Агент работает MEDOProcessingScenario
fi