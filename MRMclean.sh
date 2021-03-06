#!/bin/bash
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
lastday=$(date -d '7 day ago' +'%Y-%m-%d')
# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#Опредялем дравйер для РСУБД
JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g' |awk '{print $2}'  |grep -v name`
#Формируем путь до дравйера для РСУБД
JDBCFILELOCATION=$WFHOME/standalone/deployments/$JDBCDRIVERNAME
#получаем ip адрес cm5
IP_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $1}'`
#Получаем порт cm5
PORT_CM5=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' |awk '{print $2}'`
#Получаем название базы cm5
DB_CN5_NAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep jdbc:postgresql | sed 's/ //g'   |sed 's/\/\// /' |awk '{print $2}'  | sed 's/:/ /;s/\// /g' | sed 's/?/ /g' |awk '{print $3}'`
#полчаем юзера для РСУБД CM5
DB_CM5_USER=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep user-name  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получаем пароль для РСУБД cm5
DB_CM5_PASS=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep password  | sed 's/ //g' |sed  's/</ /g; s/>/ /g' |awk '{print $2}'`
#провряем путь до javahome systemctl status wildfly | grep Standalone  |awk '{print $2}'
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
echo $JDBCFILELOCATION "Драйдевер для рсубд"
echo $IP_CM5 "ip cm5"
echo $PORT_CM5 "Получаем порт cm5"
echo $DB_CN5_NAME "Получаем название базы cm5"
echo $DB_CM5_USER "полчаем юзера для РСУБД CM5"
echo $DB_CM5_PASS "Получаем пароль для РСУБД cm5"
#удалям задачи
$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "update idc_appliedobjlnksubform set met = 1 where id in (select ai.id from idc_task t join idc_appliedobjlnksubform ai on t.id = ai.id join idc_task_m tm on tm.owner = t.id where (t.folder = 'finished' or t.folder = 'archive') and not ai.met = '1' and not t.phase in ('3', '5') and t.lastactiondate < TIMESTAMP '$lastday 00:00:00')"