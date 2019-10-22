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
#опредляем подклюсение к рсубд

#Механизм обнаружение аварийного/сбойного состояния серверов
#Получение данных о конектах
cm5a=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CM5/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
cmja=`$WFHOME/bin/jboss-cli.sh --connect --controller=$ip:$port --commands="/subsystem=datasources/xa-data-source=CMJ/statistics=pool:read-resource(include-runtime=true)" |grep ActiveCount |sed 's/,/ /g; s/>/ /g' |awk '{print $3}'`
#считаем % для cm5
resultcm5=$(echo "$cm5a/$cm5pool" | bc -l)
#считаем % для cm5
resultcm5pool=$(echo "$resultcm5*100" |bc -l )
#расичтывем условия для cm5
if (( $(echo "$resultcm5pool > $dcm5" |bc -l) ));
then
    echo "yes"
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi
echo $resultcm5pool
#считаем % для cml
resultcmj=$(echo "$cmja/$cmjpool" | bc -l)
#считаем % для cml
resultcmjpool=$(echo "$resultcmj*100" |bc -l )
#расичтывем условия для cml
if (( $(echo "$resultcmjpool > $dcm5" |bc -l) ));
then
    echo "yes"
else
    echo "no" #пулы меньше нужного значения не чего не делаем
fi
echo $resultcmjpool
