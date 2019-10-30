#!/bin/bash
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
lastday=$(date -d '1 day ago' +'%Y-%m-%d')
# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#Опредялем дравйер для РСУБД
JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
#Формируем путь до дравйера для РСУБД
JDBCFILELOCATION=$WFHOME/standalone/deployments/$JDBCDRIVERNAME
#получаем ip адрес cm5
IP_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $1}'`
#Получаем IP адерс cmj
IP_CMJ=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $1}'`
#Получаем порт cm5
PORT_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $2}'`
#Получаем порт cmj
PORT_CMJ=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $2}'`
#Получаем название базы cm5
DB_CN5_NAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' | sed 's/?/ /g' |awk '{print $3}'`
#Получаем название базы cmj
DB_CNJ_NAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' | sed 's/?/ /g' |awk '{print $3}'`
#полчаем юзера для РСУБД CM5
DB_CM5_USER=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep user-name  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#полчаем юзера для РСУБД CMJ
DB_CMJ_USER=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep user-name  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получаем пароль для РСУБД cm5
DB_CM5_PASS=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep password  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получаем пароль для РСУБД cmj
DB_CMJ_PASS=`cat $STANDALONEXML |grep -A 30 'pool-name="CMJ"' |grep password | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#провряем путь до javahome systemctl status wildfly | grep Standalone  |awk '{print $2}'
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
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
#проверяем чейнж логи
RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "select a.description, count(a.description) from ag_data_message am join ag_agent a on am.agent=a.id where am.excluded = 1 and am.created_date > '$lastday' group by a.description order by description asc" |grep -v description`
echo $RSUBD_CM5