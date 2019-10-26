#!/bin/bash
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
# Суффикс ресурса для проверки доступности
MyAppUri="cm5div6/api/"
AuthToken=""
# %занятых пулов см5 при которых срабатывает скрипт дефолтно 95
dcm5=95
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
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorcm5=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi
echo $resultcm5pool "Результат расчета"
#считаем % для cml
resultcmj=$(echo "$cmja/$cmjpool" | bc -l)
#считаем % для cml
resultcmjpool=$(echo "$resultcmj*100" |bc -l )
#расичтывем условия для cml
if (( $(echo "$resultcmjpool > $dcm5" |bc -l) ));
then
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorcmj=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi
echo $resultcmjpool "Результат расчета"

#Модуль проверки конекшнов в базе
#Получам сколько всего конектов может использоваться в cm5
RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'show max_connections' |grep -v max_connections`
#Получаем использованыые пулы
USED_RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'SELECT COUNT(*) FROM pg_stat_activity' |grep -v count`
#считаем % для cm5
result_pool_cm5=$(echo "$USED_RSUBD_CM5/$RSUBD_CM5" | bc -l)
#считаем % для cm5
result_pool_cm5_1=$(echo "$result_pool_cm5*100" |bc -l )
echo $result_pool_cm5
echo $result_pool_cm5_1
#расичтывем условия для cm5
if (( $(echo "$result_pool_cm5_1 > $dcm5" |bc -l) ));
then
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorpoolcm5=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi

RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'show max_connections' |grep -v max_connections`
#Получаем использованыые пулы
USED_RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c 'SELECT COUNT(*) FROM pg_stat_activity' |grep -v count`
#считаем % для cm5
result_pool_cmj=$(echo "$USED_RSUBD_CMJ/$RSUBD_CMJ" | bc -l)
#считаем % для cm5
result_pool_cmj_1=$(echo "$result_pool_cmj*100" |bc -l )

#расичтывем условия для cm5
if (( $(echo "$result_pool_cmj_1 > $dcm5" |bc -l) ));
then
    echo "yes" #если да то присуждаем бал к недоступонсти системы
    errorpoolcmJ=1
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi


