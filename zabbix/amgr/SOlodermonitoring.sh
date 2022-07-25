#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=
#логин пользователя
login=
pass=
#Урл сервера
url=
port=
#Каталог куда сохранаем результаты отработки
home=/u01/CM/Error/

#ip бд от амгр
IP_AMGR=
#порт бд от амгр
PORT_AMGR=
#юзер бд от амгр
DB_AMGR_USER=
#пасс бд от амгр
DB_AMGR_PASS=
# бд от амгр
DB_AMGR_NAME=

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
pull=`cat $home/tmp/info.txt |jq .components[2].info.serverStamps | sed 's/"/ /;s/\"/ /g' | sed 's/}/ /g' | sed 's/{/ /g' | sed 's/:/ /g' | sed 's/,/ /g' |grep -v hiDigit |grep -v lowDigit  |sed s/' '//g |sed '/^$/d'`
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

if [ "$a" -ne "$b" ]
then
  echo "$a не равно $b"
  echo "(кластер мендежр разлечается)"
else
  echo  кластер мендежр совпадает $a #не чего не делаем выходим из скрипта
fi
echo "$a и $b"

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
rm -rf $home/tmp/ping_ver.txt


echo '#######################################################'
echo '##      Версии серверов  СМ                          ##'
echo '#######################################################'

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c 'select node_name from cluster_node;' |grep -v node_name |sed s/'\s'//g |sed '/^$/d' > $home/tmp/ping_ver.txt

while IFS= read -r line
do
# echo  $line:8080
	ver=`curl -u $login:$pass $line:8080/ssrv-war/api/cmj-info --silent  |grep -A 1 '<br>Version :' |grep -v '<br>Version :'`
	echo $line  $ver
done < $home/tmp/ping_ver.txt

echo '#######################################################'
echo '##             Мониторинг агентов                    ##'
echo '#######################################################'

echo Агенты asup включеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '1';" |grep -v title
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup выключеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '0';" |grep -v title
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты по расписанию включенные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1';" |grep -v title
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты по расписанию выключеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '0';" |grep -v title


$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '1' DAY  ORDER BY 1 , amm.created_date DESC;" |grep -v title |grep -v execution_status |grep -v created_date > $home/tmp/err1.txt

n=`cat $home/tmp/err1.txt |wc -l`
m=0
if [ "$m" -ne "$n" ]
then
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup включеные по. врмени выводим только те агенты где была ошибка в логе или выозращен кривой статстус ВРЕМЕНОЙ ПРОМИЖУТОК 1 ДЕНЬ
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '1' DAY  ORDER BY 1 , amm.created_date DESC;" |grep -v title |grep -v execution_status |grep -v created_date
echo Необходимо:
echo Проверить очереди и подписчиков в брокере
echo Из файла $home/agent/$(date +"%Y-%m-%d") извлечь ошибки
echo Завести заявки в jira на проблемные агенты, перед этим убедиться, что запроса уже нет
echo Убедиться, что нет накопления в очередях
else
  echo  ошибок в агентах AUSUP не обноружено #не чего не делаем выходим из скрипта
fi


$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '20' MINUTE  ORDER BY 1 , amm.created_date DESC;" |grep -v title |grep -v execution_status |grep -v created_date > $home/tmp/err2.txt
bb=`cat $home/tmp/err2.txt |wc -l`
vv=0
if [ "$bb" -ne "$vv" ]
then
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup включеные по. врмени выводим только те агенты где была ошибка в логе или выозращен кривой статстус ВРЕМЕНОЙ ПРОМИЖУТОК 20 МИНУТ
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '20' MINUTE  ORDER BY 1 , amm.created_date DESC;" |grep -v title |grep -v execution_status |grep -v created_date
echo Необходимо:
echo Проверить очереди и подписчиков в брокере
echo Из файла $home/agent/$(date +"%Y-%m-%d") извлечь ошибки
echo Завести заявки в jira на проблемные агенты, перед этим убедиться, что запроса уже нет
echo Убедиться, что нет накопления в очередях
else
  echo '#######################################################'
  echo  ошибок в агентах AUSUP за 20 минут не обноружено #не чего не делаем выходим из скрипта
fi

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (SELECT DISTINCT ON(1) trigger.title , amm.execution_status FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1' ORDER BY 1 , amm.created_date DESC) SELECT * FROM agent_list WHERE execution_status = 'ERROR';" |grep -v title |grep -v execution_status |grep -v created_date > $home/tmp/err3.txt
bb3=`cat $home/tmp/err3.txt |wc -l`
vv3=0
if [ "$bb3" -ne "$vv3" ]
then
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод ошибочных агентов по расписнию c проблемным статусом
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (SELECT DISTINCT ON(1) trigger.title , amm.execution_status FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1' ORDER BY 1 , amm.created_date DESC) SELECT * FROM agent_list WHERE execution_status = 'ERROR';" |grep -v title |grep -v execution_status |grep -v created_date
echo Необходимо:
echo Проверить очереди и подписчиков в брокере
echo Из файла $home/agent/$(date +"%Y-%m-%d") извлечь ошибки
echo Завести заявки в jira на проблемные агенты, перед этим убедиться, что запроса уже нет
echo Убедиться, что нет накопления в очередях
else
  echo '#######################################################'
  echo  Ошибок в агентах по расписанию не обнвружено #не чего не делаем выходим из скрипта
fi

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_sched_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';" |grep -v title |grep -v execution_status |grep -v created_date > $home/tmp/err4.txt
bb4=`cat $home/tmp/err4.txt |wc -l`
vv4=0
if [ "$bb4" -ne "$vv4" ]
then
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод  агентов по расписнию которые ожидают запуска
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_sched_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';" |grep -v title |grep -v execution_status |grep -v created_date
else
  echo '#######################################################'
  echo  Ожидающих агентов не обнаружено #не чего не делаем выходим из скрипта
fi

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';" |grep -v title |grep -v execution_status |grep -v created_date > $home/tmp/err5.txt
bb5=`cat $home/tmp/err5.txt |wc -l`
vv5=0
if [ "$bb5" -ne "$vv5" ]
then
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод  агентов asap которые ожидают запуска
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';" |grep -v title |grep -v execution_status |grep -v created_date
else
  echo '#######################################################'
  echo  Ожидающих ASAP агентов не обнаружено #не чего не делаем выходим из скрипта
fi
echo '#######################################################'
bb6=`$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH mass AS ( 	SELECT 		1 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'STOPPED' AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 				am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 		) UNION 	SELECT 		1 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'ERROR' AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 				am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 		) UNION 	SELECT 		0 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'RUNNING' AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 	am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 	) UNION 	SELECT 		0 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'FINISHED' AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 				am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 		) UNION 	SELECT 		1 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'WAITING' AND 		amm.created_date < current_timestamp - INTERVAL '20' MINUTE AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 				am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 		) UNION 	SELECT 		0 state 	FROM 		am_trigger_executions amm 	JOIN 		am_agent_trigger trigger 			ON trigger.id = amm.owner 	WHERE 		trigger.title = 'PGTW-AgentStructLoader' AND 		amm.execution_status = 'WAITING' AND 		amm.created_date > current_timestamp - INTERVAL '20' MINUTE AND 		amm.created_date IN ( 			SELECT 				max(amm.created_date) 			FROM 				am_trigger_executions amm 			JOIN 				am_agent_trigger trigger 					ON trigger.id = amm.owner 			WHERE 				trigger.title = 'PGTW-AgentStructLoader' 		) UNION 	SELECT 		0 state FROM 	am_trigger_executions amm JOIN 	am_agent_trigger trigger 		ON trigger.id = amm.owner JOIN 	am_trigger_agent_exec exec 		ON exec.owner = amm.id JOIN 	am_agent_exec_log log 		ON log.owner = exec.id WHERE 	trigger.title = 'PGTW-AgentStructLoader' AND 	execution_log LIKE '%Создан новый слепок от%' AND 	log.created_date IN ( 		SELECT 			max(log.created_date) 		FROM 			am_trigger_executions amm 		JOIN 			am_agent_trigger trigger 				ON trigger.id = amm.owner 		JOIN 			am_trigger_agent_exec exec 				ON exec.owner = amm.id 		JOIN 			am_agent_exec_log log 				ON log.owner = exec.id 		WHERE 			trigger.title = 'PGTW-AgentStructLoader' 	)  ) TABLE mass;" |grep -v state`
vv6=0
if [ "$bb6" -ne "$vv6" ]
then

echo Вывод  агентов PGTW-AgentStructLoader НЕ ОТРАБОТАЛ
else
  echo '#######################################################'
  echo Агент  PGTW-AgentStructLoader  успешно отработал
fi
#Получаем инфу глобальнго пинга
#првоеряем кталоги
if [ ! -d "$home" ]; then
    # Создать папку, только если ее не было
    mkdir $home
fi

if [ ! -d "$home/agent" ]; then
    # Создать папку, только если ее не было
    mkdir $home/agent
fi

if [ ! -d "$home/agent/$(date +"%Y-%m-%d")" ]; then
    # Создать папку, только если ее не было
    mkdir $home/agent/$(date +"%Y-%m-%d")
fi

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '1';" > $home/agent/$(date +"%Y-%m-%d")/$(date +"asup_agents_included-%Y-%m-%d-%H-%M").csv
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '0';" > $home/agent/$(date +"%Y-%m-%d")/$(date +"asup_agents_disabled-%Y-%m-%d-%H-%M").csv
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1';" > $home/agent/$(date +"%Y-%m-%d")/$(date +"Scheduled_agents_included-%Y-%m-%d-%H-%M").csv
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '0';"  > $home/agent/$(date +"%Y-%m-%d")/$(date +"Scheduled_Agents_Off-%Y-%m-%d-%H-%M").csv
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '1' DAY  ORDER BY 1 , amm.created_date DESC;" > $home/agent/$(date +"%Y-%m-%d")/$(date +"asup_erroneous-%Y-%m-%d-%H-%M").csv
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (SELECT DISTINCT ON(1) trigger.title , amm.execution_status FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1' ORDER BY 1 , amm.created_date DESC) SELECT * FROM agent_list WHERE execution_status = 'ERROR';"  > $home/agent/$(date +"%Y-%m-%d")/$(date +"erroneous_on_schedule-%Y-%m-%d-%H-%M").csv

$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1)  trigger.title , amm.execution_status , log.execution_log , amm.created_date ,log.created_date FROM  am_trigger_executions amm JOIN  am_agent_trigger trigger    ON trigger.id = amm.owner JOIN  am_trigger_agent_exec exec    ON exec.owner = amm.id JOIN  am_agent_exec_log log    ON log.owner = exec.id JOIN domain_object_type_id domain  ON domain.id = trigger.id_type WHERE  domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '1' DAY ORDER BY  1, amm.created_date DESC;"  > $home/agent/$(date +"%Y-%m-%d")/$(date +"ERROR_ASUP_LOG-%Y-%m-%d-%H-%M").csv

echo логи расположены в $home/agent/$(date +"%Y-%m-%d")