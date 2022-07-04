#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=/u01/CM/wildfly
#логин пользователя
login=irshk
pass=1
#Урл сервера
b=1



in=(SGO-SED-REP101
SGO-SED-AP102
SGO-SED-TECH102
SGO-SED-MRM102
SGO-SED-AP101
SGO-SED-MRM101
SGO-SED-AP107
SGO-SED-AP108
SGO-SED-VIP101
SGO-SED-AP109
SGO-SED-AP103
SGO-SED-AP105
SGO-SED-AP104
SGO-SED-AP106
SGO-SED-TECH101)


for ADDR in ${in[*]}
        do
	ver=`curl -u $login:$pass $ADDR:8080/ssrv-war/api/cmj-info --silent  |grep -A 1 '<br>Version :' |grep -v '<br>Version :'`
	echo $ver >> /u01/CM/Error/tmp_zabbix_log.txt
        done

cat /u01/CM/Error/tmp_zabbix_log.txt  | sort | uniq -cd |wc -l > /u01/CM/Error/tmp_zabbix_log_wc.txt
a=`cat /u01/CM/Error/tmp_zabbix_log_wc.txt`

if [ "$a" -eq "$b" ]
then
    echo 0

else
    echo 1
fi