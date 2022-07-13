#!/bin/bash

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
DB_AMGR_NAME=amgr
echo '#######################################################'
echo '##             Мониторинг агентов                    ##'
echo '#######################################################'

echo Агенты asup включеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '1';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup выключеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND trigger.enabled = '0';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты по расписанию включенные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты по расписанию выключеные
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT trigger.title FROM am_agent_trigger trigger JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '0';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup включеные по. врмени выводим только те агенты где была ошибка в логе или выозращен кривой статстус ВРЕМЕНОЙ ПРОМИЖУТОК 1 ДЕНЬ
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '1' DAY  ORDER BY 1 , amm.created_date DESC;"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Агенты asup включеные по. врмени выводим только те агенты где была ошибка в логе или выозращен кривой статстус ВРЕМЕНОЙ ПРОМИЖУТОК 20 МИНУТ
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "SELECT DISTINCT ON(1) trigger.title , amm.execution_status, log.created_date FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_agent_trigger' AND  trigger.enabled = '1' and log.created_date > current_timestamp - INTERVAL '20' MINUTE  ORDER BY 1 , amm.created_date DESC;"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод ошибочных агентов по расписнию c проблемным статусом
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (SELECT DISTINCT ON(1) trigger.title , amm.execution_status FROM am_trigger_executions amm JOIN am_agent_trigger trigger ON trigger.id = amm.owner JOIN am_trigger_agent_exec exec ON exec.owner = amm.id JOIN am_agent_exec_log log ON log.owner = exec.id JOIN domain_object_type_id domain ON domain.id = trigger.id_type WHERE domain.name = 'am_sched_agent_trigger' AND trigger.enabled = '1' ORDER BY 1 , amm.created_date DESC) SELECT * FROM agent_list WHERE execution_status = 'ERROR';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод  агентов по расписнию которые ожидают запуска
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_sched_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';"
echo '#######################################################'
echo '#######################################################'
echo '#######################################################'
echo Вывод  агентов asap которые ожидают запуска
$my_java_home -cp $JDBCFILELOCATION":/u01/CM/script/SoLoader/"  PostgresqlQueryExecuteJDBC  -h $IP_AMGR -p $PORT_AMGR -U $DB_AMGR_USER -W $DB_AMGR_PASS -d $DB_AMGR_NAME -c "WITH agent_list AS (  SELECT DISTINCT ON(1)    trigger.title  , amm.execution_status  ,  amm.created_date  FROM    am_trigger_executions amm  JOIN am_agent_trigger trigger ON trigger.id = amm.owner  JOIN    am_trigger_agent_exec exec      ON exec.owner = amm.id  JOIN    am_agent_exec_log log      ON log.owner = exec.id  JOIN    domain_object_type_id domain      ON domain.id = trigger.id_type  WHERE    domain.name = 'am_agent_trigger' AND    trigger.enabled = '1'  ORDER BY    1  , amm.created_date DESC)SELECT  * FROM  agent_list WHERE  execution_status = 'WAITING';"

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