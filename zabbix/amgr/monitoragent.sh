#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
#Каталог куда сохранаем результаты отработки
home=/u01/CM/Error/
#Опредялем дравйер для РСУБД
#JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g'  |grep -v 'name="h2"' |awk '{print $2}'`
#Формируем путь до дравйера для РСУБД
#JDBCFILELOCATION=$WFHOME/standalone/deployments/$JDBCDRIVERNAME
JDBCFILELOCATION=$WFHOME/standalone/deployments/postgresql-42.2.5.jar
#ip бд от амгр
IP_AMGR=
#порт бд от амгр
PORT_AMGR=
#юзер бд от амгр
DB_AMGR_USER=
#пасс бд от амгр
DB_AMGR_PASS=
# бд от амгр
DB_AMGR_NAME=amgr

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
  echo  ошибок в агентах AUSUP за 20 минут не обнаружено #не чего не делаем выходим из скрипта
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
  echo  Ошибок в агентах по расписанию не обнаружено #не чего не делаем выходим из скрипта
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