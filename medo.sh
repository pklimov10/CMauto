#!/bin/bash
#куда сохраняем отчет
REPORT_FILE=/opt/medo/$(date +"%Y-%m-%d-%H-%M").csv
#дата за которую ищем документы
DATE=`date +%Y-%m-%d`
#Адрес РСУБД МЭДО сревреа
MEDO_DB_ADDRESS=
#порт к базе РСУБД МЭДО
PORT_MEDO=5432
#Логин к базе РСУБД МЭДО
LOGIN_MEDO=postgres
#Пароль к базе рсубд МЭДО
PASSWD_MEDO=
#Название базы рсубд
DB_NAME_MEDO=cmjdbmedo
#домашня дериктория WF
WFHOME=/opt/wildfly
# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#Опредялем дравйер для РСУБД
JDBCDRIVERNAME=`cat $STANDALONEXML |grep -A 30 'pool-name="CM5"'  |grep driver | sed 's/</ /g; s/>/ /g' |awk '{print $2}'`
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

echo "Поступило пакетов из МЭДО"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $MEDO_DB_ADDRESS -p $PORT_MEDO -U $LOGIN_MEDO -W $PASSWD_MEDO -d $DB_NAME_MEDO -c  "select count(distinct(e.*))
from esd e
join service_consumer sc on e.service_consumer = sc.id
join event_log el on el.esd = e.id
join event_type et on el.event_type = et.id
where e.created_date between '$DATE 00:00:00' and '$DATE 23:59:59'
and not (lower(e.theme) like '%квитанция%' or lower(e.theme) like '%уведомление%')
and lower(et.name) = lower('получение')
and sc.name='Default';" >> $REPORT_FILE


echo "Передано проектов в СМ5 из МЭДО"  >> $REPORT_FILE
echo "" >> $REPORT_FILE


$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $MEDO_DB_ADDRESS -p $PORT_MEDO -U $LOGIN_MEDO -W $PASSWD_MEDO -d $DB_NAME_MEDO -c "select count(distinct(e.*))
from esd e
join service_consumer sc on e.service_consumer = sc.id
join event_log el on el.esd = e.id
join event_type et on el.event_type = et.id
where e.created_date between '$DATE 00:00:00' and '$DATE 23:59:59'
and not (lower(e.theme) like '%квитанция%' or lower(e.theme) like '%уведомление%')
and lower(et.name) = lower('отправка')
and sc.name='Default';" >> $REPORT_FILE


echo "Доставлено пакетов в СМ5 из МЭДО"  >> $REPORT_FILE
echo "" >> $REPORT_FILE


$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $MEDO_DB_ADDRESS -p $PORT_MEDO -U $LOGIN_MEDO -W $PASSWD_MEDO -d $DB_NAME_MEDO -c "select count(distinct(e.*))
from esd e
join service_consumer sc on e.service_consumer = sc.id
join event_log el on el.esd = e.id
join event_type et on el.event_type = et.id
where e.created_date between '$DATE 00:00:00' and '$DATE 23:59:59'
and not (lower(e.theme) like '%квитанция%' or lower(e.theme) like '%уведомление%')
and lower(et.name) = lower('доставка')
and sc.name='Default';" >> $REPORT_FILE

echo "Создано проектов по пакетам из МЭДО в СМ5 входящие"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "with dates as (select '$DATE 00:00:00.000'::timestamp as date_start , '$DATE 23:59:59.000'::timestamp as date_end)
select count(distinct(f_dp_inputrkk.*))
from f_dp_rkkbase join f_dp_inputrkk on f_dp_inputrkk.id=f_dp_rkkbase.id
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ))
and f_dp_inputrkk.medogatestate=2;" >> $REPORT_FILE

echo "Создано проектов по пакетам из МЭДО в СМ5 ОГ"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "with dates as (select '$DATE 00:00:00.000'::timestamp as date_start , '$DATE 23:59:59.000'::timestamp as date_end)
select count(distinct(f_dp_requestrkk.*))
from f_dp_rkkbase join f_dp_requestrkk  on f_dp_requestrkk.id=f_dp_rkkbase.id
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ))
and f_dp_requestrkk.medogatestate=2;" >> $REPORT_FILE

echo "Проверяем общее количество принятых/отправленных документов за сутки по б/д cm5"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "with dates as (select '$DATE 00:00:00.000'::timestamp as date_start , '$DATE 23:59:59.000'::timestamp as date_end)
select 'Отправлено', count(distinct(f_dp_rkkbase.id))
from f_dp_rkkbase join f_dp_outputrkk on f_dp_outputrkk.id=f_dp_rkkbase.id
join f_dp_rkk_medo on f_dp_rkk_medo.owner=f_dp_outputrkk.id
where (not f_dp_rkkbase.medo_doc_guid is null)
and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkk_medo.created_date between (select date_start from dates ) and (select date_end from dates ))
union
select 'Принято ВхД',count (f_dp_rkkbase.id)
from f_dp_rkkbase join f_dp_inputrkk on f_dp_inputrkk.id=f_dp_rkkbase.id
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ))
union
select 'Принято ОГ', count (f_dp_rkkbase.id)
from f_dp_rkkbase join f_dp_requestrkk on f_dp_requestrkk.id=f_dp_rkkbase.id
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ))" >> $REPORT_FILE

echo "Полученные во Входящие (по cm5)"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "with dates as (select '$DATE 00:00:00.000'::timestamp as date_start , '$DATE 23:59:59.000'::timestamp as date_end)
select DISTINCT (nunid2punid_map.nunid) as nunid, f_dp_rkkbase.id as rkk_id,f_dp_inputrkk.foreignnumber as fnumber, Upper(f_dp_rkkbase.medo_doc_guid) ,f_dp_rkkbase.subject as subj,f_dp_rkk.regdate as rdate
from f_dp_rkkbase join f_dp_inputrkk on f_dp_inputrkk.id=f_dp_rkkbase.id
join f_dp_rkk on f_dp_rkk.id=f_dp_rkkbase.id
join domain_object_type_id on domain_object_type_id.id=f_dp_inputrkk.id_type
join nunid2punid_map on (((substring(nunid2punid_map.punid,5,12):: bigint)=f_dp_inputrkk.id) and (substring(nunid2punid_map.punid,0,5):: bigint)=f_dp_inputrkk.id_type)
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ));" >> $REPORT_FILE

echo "Полученные в ОГ за сутки"  >> $REPORT_FILE
echo "" >> $REPORT_FILE

$my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "with dates as (select '$DATE 00:00:00.000'::timestamp as date_start , '$DATE 23:59:59.000'::timestamp as date_end)
select DISTINCT (nunid2punid_map.nunid) as nunid, f_dp_rkkbase.id as rkk_id,f_dp_sp.regnumber as fnumber, SUBSTRING (f_dp_rkkbase.subject,1, 90) as subj, f_dp_requestrkk.corrlastname as lastname, f_dp_requestrkk.corrfirstname as firstname
from f_dp_rkkbase join f_dp_requestrkk on f_dp_requestrkk.id=f_dp_rkkbase.id
join f_dp_rkk on f_dp_rkk.id=f_dp_rkkbase.ida
join f_dp_sp on f_dp_sp.hierroot=f_dp_rkkbase.id
join domain_object_type_id on domain_object_type_id.id=f_dp_requestrkk.id_type
join nunid2punid_map on (((substring(nunid2punid_map.punid,5,12):: bigint)=f_dp_requestrkk.id) and (substring(nunid2punid_map.punid,0,5):: bigint)=f_dp_requestrkk.id_type)
where (not f_dp_rkkbase.medo_doc_guid is null) and (f_dp_rkkbase.medo_doc_guid<>'')
and (f_dp_rkkbase.created_date between (select date_start from dates ) and (select date_end from dates ));" >> $REPORT_FILE