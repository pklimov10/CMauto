#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=/u01/CM/wildfly
#логин пользователя
login=irshk
pass=1
#Урл сервера
url=sgo-sed-tech101
port=8080
#Каталог куда сохранаем результаты отработки
home=/u01/CM/Error

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
USED_RSUBD_CM5=`$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'select COUNT(cmjunid)  from so_beard where isactive = 1 and orig_type in (0, 1, 2, 3,4)' |grep -v count`
RSUBD_CMJ=`$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "select count(unid) from so_beards where isactive = true and original_type in ('SYS_ORGANIZATION', 'SYS_DEPARTMENT', 'SYS_HUMAN', 'SYS_HUMAN_HEAD', 'SYS_ROLE')" |grep -v count`
OTVER_CM5=$(( $USED_RSUBD_CM5-6000 ))
let OTVET=OTVER_CM5-RSUBD_CMJ
echo 'Колизия в данных составляет:' $OTVET 'и не может больш 800'
echo  'Отсечки  SOloader'
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "SELECT * FROM lch_scaninfo"



echo '##################################################'
echo '## Количетсво нод по результатом глобаного пинга##'
echo '##################################################'

######
#Получаем инфу глобальнго пинга
#првоеряем кталоги
if [ ! -d "$home" ]; then
    # Создать папку, только если ее не было
    mkdir $home
fi

if [ ! -d "$home/tmp" ]; then
    # Создать папку, только если ее не было
    mkdir $home/tmp
fi

if [ ! -d "$home/$(date +"%Y-%m-%d")" ]; then
    # Создать папку, только если ее не было
    mkdir $home/$(date +"%Y-%m-%d")
fi

#записываем временый результат
curl -u $login:$pass $url:$port/ssrv-war/af5-services/globalcache/ping/1000 --silent > $home/tmp/ping.txt

#Зполняем постояный результат
curl -u $login:$pass $url:$port/ssrv-war/af5-services/globalcache/ping/1000 --silent | jq > $home/$(date +"%Y-%m-%d")/$(date +"ping-%Y-%m-%d-%H-%M").csv

curl -u $login:$pass $url:$port/ssrv-war/af5-services/af5-server/info --silent > $home/tmp/info.txt

curl -u $login:$pass $url:$port/ssrv-war/af5-services/af5-server/info --silent | jq > $home/$(date +"%Y-%m-%d")/$(date +"info-%Y-%m-%d-%H-%M").csv

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CMJ -p $PORT_CMJ -U $DB_CMJ_USER -W $DB_CMJ_PASS -d $DB_CNJ_NAME -c "SELECT * FROM lch_scaninfo" > $home/$(date +"%Y-%m-%d")/$(date +"lch_scaninfo-%Y-%m-%d-%H-%M").csv

### Начинаем обратботку входящих данных


cat $home/tmp/ping.txt  |jq '.nodeInfos[] | .nodeName' |sed 's/"/ /;s/\"/ /g' |wc -l

##cat  info.txt |jq '.components[1].info | ."pool-size"' ###кол вово пулов щас не нужно на будущие

echo '###############################################################'
echo '## Список сереров по результам информации мониторинга и рсубд##'
echo '###############################################################'

#Получение юнидов из мониторинга
pull=`cat $home/tmp/info.txt |jq .components[0].info.serverStamps | sed 's/"/ /;s/\"/ /g' | sed 's/}/ /g' | sed 's/{/ /g' | sed 's/:/ /g' | sed 's/,/ /g' |grep -v hiDigit |grep -v lowDigit  |sed s/' '//g |sed '/^$/d'`
for app in ${pull[*]}
        do
        $my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "SELECT node_name from cluster_node WHERE node_id = '$app'" |grep -v node_name
        $my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "SELECT node_name from cluster_node WHERE node_id = '$app'" |grep -v node_name >> $home/tmp/ping_1.txt
done
echo '#################################################################'
echo '## Кластер менджер по результам информации мониторинга и рсубд ##'
echo '#################################################################'
#Получаем кластер менджер из БД
a=`$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'SELECT node_name from cluster_node WHERE node_id = (SELECT node_id from cluster_manager)' |grep -v node_name`
#Получаем клстер менджер из глобального кеша
b=`cat $home/tmp/ping.txt  |jq .initiator | sed 's/"/ /;s/\"/ /g' |sed s/' '//g`

#if [ "$a" -ne "$b" ]
#then
#  echo "$a не равно $b"
#  echo "(кластер мендежр разлечается)"
#else
#  echo  кластер мендежр совпадает $a #не чего не делаем выходим из скрипта
#fi
echo $b
echo $a
echo '#######################################################'
echo '## Сравниваем кол во сервер в БД и в глобальном кеше ##'
echo '#######################################################'

c=`cat $home/tmp/ping.txt  |jq '.nodeInfos[] | .nodeName' |sed 's/"/ /;s/\"/ /g' |wc -l`
v=`cat $home/tmp/ping_1.txt |wc -l`

if [ "$c" -ne "$v" ]
then
  echo "$c не равно $v"
else
  echo  количество совпадает $a #не чего не делаем выходим из скрипта
fi

echo '#######################################################'
echo '##    Время последней инвалидации глобального  кеша  ##'
echo '#######################################################'

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'SELECT updated_date, node_name from cluster_node'
rm -rf $home/tmp/ping_1.txt
cat /dev/null > $home/tmp/ssql.txt
echo '#######################################################'
echo '##                Очередь инвалидации                ##'
echo '#######################################################'

pull_1=`cat $home/tmp/info.txt |jq '.components[0].info.invalidationInfo | .invalidationQueueSizeMap' | sed 's/"/ /;s/\"/ /g' | sed 's/:/ /g' | sed 's/}/ /g' | sed 's/{/ /g' | sed 's/:/ /g' | sed 's/,/ /g' | sed 's/^.//' | sed 's/^.//' | sed 's/^.//' |sed '/^$/d' |awk '{print $1}'`
for app1 in ${pull_1[*]}
do
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "SELECT node_id, node_name from cluster_node WHERE node_id = '$app1'" |grep -v node_name |grep -v node_id  >> $home/tmp/ssql.txt
done

cat $home/tmp/info.txt |jq '.components[0].info.invalidationInfo | .invalidationQueueSizeMap' | sed 's/"/ /;s/\"/ /g' | sed 's/:/ /g' | sed 's/}/ /g' | sed 's/{/ /g' | sed 's/:/ /g' | sed 's/,/ /g' | sed 's/^.//' | sed 's/^.//' | sed 's/^.//' |sed '/^$/d' > $home/tmp/components.txt

join $home/tmp/ssql.txt $home/tmp/components.txt

#Выаодим poolSize
poolSize=`cat $home/tmp/info.txt |jq '.components[0].info.invalidationInfo | .invalidationThreadPoolExecutorInfo' |grep poolSize |awk '{print $2}' | sed 's/,/ /g'`
#Выаодим queueSize
queueSize=`cat $home/tmp/info.txt |jq '.components[0].info.invalidationInfo | .invalidationThreadPoolExecutorInfo' |grep queueSize |awk '{print $2}' | sed 's/,/ /g'`
#Выаодим activeCount
activeCount=`cat $home/tmp/info.txt |jq '.components[0].info.invalidationInfo | .invalidationThreadPoolExecutorInfo' |grep activeCount |awk '{print $2}' | sed 's/,/ /g'`
echo "poolSize $poolSize - кол-во потоков, которые будут разгребать инвалидации "
echo "queueSize $queueSize - очередь заданий на инвалидацию"
echo "activeCount $activeCount - сколько в данную секунду работает потоков из poolSize"
cat /dev/null > $home/tmp/ssql.txt