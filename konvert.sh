#!/bin/bash
#Учетка для сброса
APP=`ls -la ~/files/*`

for ADDR in ${APP[*]}
        do
         iconv -f us-ascii -t CP1251 $APP -o /opt/test/$APP.out
        done
echo "Dropcache all done"