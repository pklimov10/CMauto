#!/bin/bash
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
#Путь куда сохранем отчет об авраии
ERRORHOME=/opt/error/
# Суффикс ресурса для проверки доступности
MyAppUri="cm5div6/api/"
AuthToken="login:password"
# %занятых пулов см5 при которых срабатывает скрипт дефолтно 95
dcm5=95
# %занятых пулов смj при которых срабатывает скрипт дефолтно 95
dcmj=95
# %занятых окнекшанов см5 при которых срабатывает скрипт дефолтно 70
dbcmj=70
# %занятых окнекшанов смJ при которых срабатывает скрипт дефолтно 95
dbcm5=70
#кол во озу в мегобайтах когда скрипт срабатывает
oom=90000
#число ошибок когда начинаем собирать
maxerror=2
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
#формируем урл до api
CHECKURL="http://"$ip":"$hhtpport"/"$MyAppUri
#Опереляем пул соедений cm5
cm5pool=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"' |grep "<max-pool-size>" |sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
#Опрелялем пул соденией cmj
cmjpool=`cat $STANDALONEXML |grep -A 30  'pool-name="CMJ"' |grep "<max-pool-size>" |sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
#Получение данных о конектах
cm5a=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
cmja=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CMJ/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
#провряем путь до javahome systemctl status wildfly | grep Standalone  |awk '{print $2}'
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
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
#считаем % для cm5
resultcm5=$(echo "$cm5a/$cm5pool" | bc -l)
#считаем % для cm5
resultcm5pool=$(echo "$resultcm5*100" |bc -l )
#расичтывем условия для cm5
if (( $(echo "$resultcm5pool > $dcm5" |bc -l) ));
then
    echo "yes" "если да то присуждаем бал к недоступонсти системы"
    errorcm5=1
else
    echo "no" "пулы меньше нужного значения не чего не делаем"
    errorcm5=0
fi
echo $resultcm5pool "Результат расчета"
#считаем % для cml
resultcmj=$(echo "$cmja/$cmjpool" | bc -l)
#считаем % для cml
resultcmjpool=$(echo "$resultcmj*100" |bc -l )
#расичтывем условия для cml
if (( $(echo "$resultcmjpool > $dcmj" |bc -l) ));
then
    echo "yes" "если да то присуждаем бал к недоступонсти системы"
    errorcmj=1
else
    echo "no" "пулы меньше нужного значения не чего не делаем"
    errorcmj=0
fi
echo $resultcmjpool "Результат расчета"

#Модуль проверки конекшнов в базе
#Получам сколько всего конектов может использоваться в cm5
RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'show max_connections' |grep -v max_connections`
echo $RSUBD_CM5 'всего пулов к cm5'
#Получаем использованыые пулы
USED_RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'SELECT COUNT(*) FROM pg_stat_activity' |grep -v count`
echo $USED_RSUBD_CM5 'пулов занято к базе см5 '
#считаем % для cm5
result_pool_cm5=$(echo "$USED_RSUBD_CM5/$RSUBD_CM5" | bc -l)
#считаем % для cm5
result_pool_cm5_1=$(echo "$result_pool_cm5*100" |bc -l )
echo $result_pool_cm5 '% cm5'
echo $result_pool_cm5_1 '% пулов занято к базе см5'
#расичтывем условия для cm5
if (( $(echo "$result_pool_cm5_1 > $dbcm5" |bc -l) ));
then
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorpoolcm5=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
    errorpoolcm5=0
fi

RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'show max_connections' |grep -v max_connections`
echo $RSUBD_CMJ 'Получаем  пулы cmj'
#Получаем использованыые пулы
USED_RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'SELECT COUNT(*) FROM pg_stat_activity' |grep -v count`
echo $USED_RSUBD_CMJ 'олучаем использованыые пулы cmj'
#считаем % для cm5
result_pool_cmj=$(echo "$USED_RSUBD_CMJ/$RSUBD_CMJ" | bc -l)
#считаем % для cm5
result_pool_cmj_1=$(echo "$result_pool_cmj*100" |bc -l )
echo $result_pool_cmj '% cmj'
echo $result_pool_cmj_1 '% пулов занято к базе смj'
#расичтывем условия для cm5
if (( $(echo "$result_pool_cmj_1 > $dbcmj" |bc -l) ));
then
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorpoolcmJ=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
    errorpoolcmJ=0
fi
#Проверяем дотсупоность API системы
if curl -u $AuthToken $CHECKURL -m 10 |grep $hhtpport
then
  echo $CHECKURL 'все норм'
  httperror=0
else
  echo $CHECKURL 'присваем бал аврии'
  httperror=1
fi
#проверяем кол во ОЗУ в систтеме
if [ "$ozy" -le "$oom" ]
then
  oomerror=1
else
  echo 'идем дальше'
  oomerror=0
fi
#Проверяем доступность службы если службы выключена то выходим
ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
result=$(echo $ps_out | grep "$1")
if [[ "$result" != "" ]];then
    echo "Running"
else
    echo "Not Running"
    exit
fi

#Собираем информацию при аврии
errorrate=$(echo "$errorcm5+$errorcmj+$errorpoolcm5+$errorpoolcmJ+$httperror+$oomerror" |bc -l )
if (( $(echo "$errorrate >= $maxerror" |bc -l) ));
then
    echo "yes" #Насиниаем мбор информации об аврии
    #Собираем и архивируем лог
    #Собираем инормацию о пулах
    #СОбиранем информацию о конекшинах
    tar -czf $ERRORHOME/$(date +"%Y-%m-%d-%H-%M").tar.gz $WFHOME/standalone/log/*
    $WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)" > $ERRORHOME/infopoolcm5.csv
    $WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CMJ/statistics=pool:read-resource(include-runtime=true)" > $ERRORHOME/infopoolcmj.csv
    $my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity' > $ERRORHOME/$(date +"zapros-CM5-%Y-%m-%d-%H-%M").csv
    $my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'select (now() - query_start) as time_in_progress, datname, pid, state, client_addr, client_hostname, client_port, query from pg_stat_activity' > $ERRORHOME/$(date +"zapros-CMJ-%Y-%m-%d-%H-%M").csv
    PID=$(jps -v |grep "\-Dlogging.configuration=file:$WFHOME/standalone" |grep Xmx |awk '{print $1}')
    echo $PID
    jstack -F $PID >> $ERRORHOME/$(date +"ThreadDump-%Y-%m-%d-%H-%M").csv


else
    echo "no" #не чего не делаем выходим из скрипта
fi