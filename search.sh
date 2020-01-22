#!/bin/bash
#Токен бота
TOKEN=
#id чата
CHAT_ID=
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
#утилита searcher-0.0.8.jar можно с путем /opt/searcher-0.0.8.jar
searcher=/opt/select/searcher-0.0.8.jar
#<путь до папки с файлом application.properties
properties=/opt/select/
#порт на котром запускаем утилиту (порт не должен быть занят)
port=6969
#куда сохраняем csv
my_dir_csv=/opt/select
#парметры формирования csv
#где objectType принимает 3 значения:
#rkk - если интересуют задачи / уведомления, созданные по РКК (адресация);
#resolution - задачи / уведомления, которые должны были быть созданы на основании резолюции (исполнение, контроль);
#all - и РКК, и резолюция.
objectType=resolution
#operation - принимает 3 значения:
#created - то есть задачи/уведомления, которые должны были быть созданы на основании факта создания или публикации документа;
#modified - задачи/уведомления, которые должны были быть созданы на основании факта редактирования списка адресатов (для РКК) или исполнителей и контроля (для резолюций);
#all - совокупность 1 и 2 пунктов.
operation=all
#формируем дату 1 день назад
dateFrom=$(date -d "1 day ago" +"%Y-%m-%d%%2000:00:00")
#Формируем дату сегодня -3 часа
dateTo=$(date +"%Y-%m-%d%%2000:00:00")
nameCSV=$(date +"%Y-%m-%d-%H-%M").csv
# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#Опредялем дравйер для РСУБД
JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g' |grep -v 'name="h2"' |awk '{print $2}'`
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
#вормируем CSV
cd $properties
csv_dir=$my_dir_csv/$nameCSV
$my_java_home -jar $searcher --server.port=$port & sleep 40  && wget -P $my_dir_csv/ -O $nameCSV http://127.0.0.1:6969/search/absent/$objectType/$operation/$dateFrom/$dateTo -T 0
#убиваем java процес серчера
my_kill=$(ps -ef | grep java |grep $searcher |awk '{print $2}')
echo $my_kill
kill -9 $my_kill
RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "select replica from ss_module where type in (select id  from ss_moduletype where alias like '%Prev%');" |grep -v replica `
for ADDR in ${RSUBD_CM5[*]}
        do
         sed -i "/$ADDR/d" $my_dir_csv/$nameCSV
        done

curl -F chat_id=$CHAT_ID -F document=@"$csv_dir" -F caption="CSV" http://185.112.82.9:85/bot$TOKEN/sendDocument
