#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
#Если wf выключин то выходим из скрипта
ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
result=$(echo $ps_out | grep "$1")
if [[ "$result" != "" ]];then
    echo "Running"
else
    echo "Not Running"
    exit
fi

# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#провряем путь до javahome systemctl status wildfly | grep Standalone  |awk '{print $2}'
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
#Опредялем дравйер для РСУБД
JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g'  |grep -v 'name="h2"' |awk '{print $2}'`
#Формируем путь до дравйера для РСУБД
JDBCFILELOCATION=$WFHOME/standalone/deployments/$JDBCDRIVERNAME
#получаем ip адрес cm5
IP_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $1}'`
#Получаем IP адерс cmj
IP_CMJ=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |grep -v cm6 |grep -v cm5 |awk '{print $1}'`
#Получаем порт cm5
PORT_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $2}'`
#Получаем порт cmj
PORT_CMJ=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |grep -v cm6 |grep -v cm5  |awk '{print $2}'`
#Получаем название базы cm5
DB_CN5_NAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' | sed 's/?/ /g' |awk '{print $3}'`
#Получаем название базы cmj
DB_CNJ_NAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' | sed 's/?/ /g' |grep -v cm6 |grep -v cm5  |awk '{print $3}'`
#полчаем юзера для РСУБД CM5
DB_CM5_USER=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep user-name  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#полчаем юзера для РСУБД CMJ
DB_CMJ_USER=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep user-name  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получаем пароль для РСУБД cm5
DB_CM5_PASS=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep password  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получаем пароль для РСУБД cmj
DB_CMJ_PASS=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep password | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
echo $JDBCFILELOCATION "Драйдевер для рсубд"
echo $IP_CM5 "ip cm5"
echo $IP_CMJ "ip cmj"
echo $PORT_CM5 "Получаем порт cm5"
echo $PORT_CMJ "Получаем порт cmj"
echo $DB_CN5_NAME "Получаем название базы cm5"
echo $DB_CNJ_NAME "Получаем название базы cmj"
echo $DB_CM5_USER "полчаем юзера для РСУБД CM5"
echo $DB_CMJ_USER "полчаем юзера для РСУБД CMJ"
echo $DB_CM5_PASS "Получаем пароль для РСУБД cm5"
echo $DB_CMJ_PASS "Получаем пароль для РСУБД cmj"
#читмае сколько в cm5
USED_RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'select COUNT(cmjunid)  from so_beard where isactive = 1 and orig_type in (0, 1, 2, 3,4)' |grep -v count`
RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "select count(unid) from so_beards where isactive = true and original_type in ('SYS_ORGANIZATION', 'SYS_DEPARTMENT', 'SYS_HUMAN', 'SYS_HUMAN_HEAD', 'SYS_ROLE')" |grep -v count`
let OTVER_CM5=$USED_RSUBD_CM5-6000`
let OTVET=OTVER_CM5-RSUBD_CMJ

echo 'Колизия в данных составляет' $OTVET 'может быть но не больш 800'

echo  'Отсечки  SOloader'
$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "SELECT * FROM lch_scaninfo"