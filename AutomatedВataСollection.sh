#!/bin/bash
#переменные окружения
#Путь до WildflyHome например /opt/wildfly
WFHOME=/opt/wildfly

# Ручной ввод закончен, дальше вычисляется автоматически. Править при необходимости
STANDALONEXML=$WFHOME/standalone/configuration/standalone.xml
#Получение ip сервера
ip=`cat $STANDALONEXML |grep "jboss.bind.address.management" | sed  's/:/ /g; s/}/ /g;  s/jboss.bind.address.management/ /g' |awk '{print $3}'`
#Вычесляем смещение портов
ofset=`cat $STANDALONEXML |grep "jboss.socket.binding.port-offset" | sed  's/:/ /g; s/}/ /g;  s/jboss.socket.binding.port-offset/ /g' |awk '{print $5}'`
#Получение менджер порта
mport=`cat $STANDALONEXML |grep "jboss.management.http.port" | sed  's/:/ /g; s/}/ /g;  s/jboss.management.http.port/ /g' |awk '{print $5}'`
#Механизм обнаружение аварийного/сбойного состояния серверов

#Получение данных о конектах
$WFHOME/bin/jboss-cli.sh --connect --controller=ip:port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)"
$WFHOME/bin/jboss-cli.sh --connect --controller=ip:port --commands="/subsystem=datasources/xa-data-s/ource=CMJ/statistics=pool:read-resource(include-runtime=true)"