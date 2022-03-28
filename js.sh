#!/bin/bash
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly
#Путь куда сохранем отчет об авраии
ERRORHOME=/opt/error/test1/
tgz="$(date +"%Y-%m-%d-%H-%M")"
mkdir $ERRORHOME/$tgz
PID=$(/хуй/хуй/хуй/jps -v |grep "\-Dlogging.configuration=file:$WFHOME/standalone" |grep Xmx |awk '{print $1}')
echo $PID
jstack -F $PID >> $ERRORHOME/$tgz/$(date +"ThreadDump-%Y-%m-%d-%H-%M").csv
jstat -gccapacity $PID >> $ERRORHOME/$tgz/$(date +"gcc-%Y-%m-%d-%H-%M").csv