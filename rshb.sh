#!/bin/bash
while true; do
  # Do something
  #Время в сиундах сколько скрипт спит
  sleep 15;
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
#Путь куда сохранем отчет об авраии
ERRORHOME=/opt/error/2/
# Суффикс ресурса для проверки доступности
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
#Получение ip сервера
ip=`cat $STANDALONEXML |grep "jboss.bind.address.management" | sed  's/:/ /g; s/}/ /g;  s/jboss.bind.address.management/ /g' |awk '{print $3}'`
#Вычесляем смещение портов
ofset=`cat $STANDALONEXML |grep "jboss.socket.binding.port-offset" | sed  's/:/ /g; s/}/ /g;  s/jboss.socket.binding.port-offset/ /g' |awk '{print $5}'`
#Получение менджер порта
mport=`cat $STANDALONEXML |grep "jboss.management.http.port" | sed  's/:/ /g; s/}/ /g;  s/jboss.management.http.port/ /g' |awk '{print $5}'`
#Вычесляем порт
let "port = ofset + mport"
#проверяем что ip в конфиге не 0.0.0.0
if [ "$ip" = "0.0.0.0" ]
  then
    ip=127.0.0.1
  fi
#определяем http port
hport=`cat $STANDALONEXML |grep jboss.http.port |sed 's/ //g; s/jboss.http.port:/ /g; s/}/ /g' | awk '{print $2}'`
#расчитываем офсет http порта
let "hhtpport = ofset + hport"
#Опереляем пул соедений cm5
cm5pool=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep "<max-pool-size>" |sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
#Опрелялем пул соденией cmj
cmjpool=`cat $STANDALONEXML |grep -A 30  'pool-name="CMJ"' |grep "<max-pool-size>" |sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получение данных о конектах
#cm5a=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
#cmja=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CMJ/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
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
#получаем кол-во озу на сервере
ozy=$(free -m | grep Mem | awk '{print $4}')
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
#Механизм обнаружение аварийного/сбойного состояния серверов

#Проверяем доступность службы если службы выключена то выходим
ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
result=$(echo $ps_out | grep "$1")
if [[ "$result" != "" ]];then
    echo "Running"
else
    echo "Not Running"
    exit
fi


    #echo "yes" #Насиниаем мбор информации об аврии
    #Собираем и архивируем лог
    #Собираем инормацию о пулах
    #СОбиранем информацию о конекшинах
    tgz="$(date +"%Y-%m-%d-%H")"
    today=`date '+%Y-%m-%d--%H-%M-%S'`;

    if ! [ -d $ERRORHOME/$tgz ]; then
mkdir $ERRORHOME/$tgz
fi
#Получение данных о конектах
$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)" > $ERRORHOME/cm5.tmp
$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CMJ/statistics=pool:read-resource(include-runtime=true)" > $ERRORHOME/cmj.tmp
    #tar -czf $ERRORHOME/$tgz/$(date +"%Y-%m-%d-%H-%M").tar.gz $WFHOME/standalone/log/ ##Переработь сборщик логов сисмтемы
    { echo -n $today  \ & cat $ERRORHOME/cm5.tmp |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}' ; } >> $ERRORHOME/$tgz/infopoolcm5.csv
    { echo -n $today  \ & cat $ERRORHOME/cmj.tmp |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}' ; } >> $ERRORHOME/$tgz/infopoolcmj.csv
    #СЛЕД 4 СТРОЧКИ МОНИТОРИНГ БАЗ ЕСЛИ НУЖНО РАСКОМЕНТИТЬ
    #$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity ORDER BY  time_in_progress desc' >> $ERRORHOME/$tgz/$(date +"zapros-CM5-%Y-%m-%d-%H").csv
    #$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity ORDER BY  time_in_progress desc' >> $ERRORHOME/$tgz/$(date +"zapros-CMJ-%Y-%m-%d-%H").csv
    #$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity where state = 'active' ORDER BY  time_in_progress desc" >> $ERRORHOME/$tgz/$(date +"zapros-active-CM5-%Y-%m-%d-%H").csv
    #$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity where state = 'active' ORDER BY  time_in_progress desc" >> $ERRORHOME/$tgz/$(date +"zapros-active-CMJ-%Y-%m-%d-%H").csv
APP=(ActiveCount
AvailableCount
AverageBlockingTime
AverageCreationTime
AverageGetTime
AveragePoolTime
AverageUsageTime
BlockingFailureCount
CreatedCount
DestroyedCount
IdleCount
InUseCount
MaxCreationTime
MaxGetTime
MaxPoolTime
MaxUsageTime
MaxUsedCount
MaxWaitCount
MaxWaitTime
TimedOut
TotalBlockingTime
TotalCreationTime
TotalGetTime
TotalPoolTime
TotalUsageTime
WaitCount)
  for ADDR in ${APP[*]}
        do
        { echo -n $today  \ $ADDR \ & cat $ERRORHOME/cm5.tmp |grep $ADDR |sed 's/,/ /g; s/>/ /g' |awk '{print $3}' ; } >> $ERRORHOME/$tgz/All_Info_CM5.csv
        { echo -n $today  \ $ADDR \ & cat $ERRORHOME/cmj.tmp |grep $ADDR |sed 's/,/ /g; s/>/ /g' |awk '{print $3}' ; } >> $ERRORHOME/$tgz/All_Info_CMJ.csv
        done
PID=$(/u01/CM/java/bin/jps -v |grep "\-Dlogging.configuration=file:$WFHOME/standalone" |grep Xmx |awk '{print $1}')
echo $PID
#jstack -F $PID >> $ERRORHOME/$tgz/$(date +"ThreadDump-%Y-%m-%d-%H-%M").csv
/u01/CM/java/bin/jstat -gccapacity $PID >> $ERRORHOME/$tgz/$(date +"gcc-%Y-%m-%d-%H-%M").csv
done

рубль.10
молоко дроде бутылки на рубдь
10к

1.10-1=10

x-y
1.10

