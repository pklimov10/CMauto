#!/bin/bash
#Учетка для сброса
LOGIN=login:pass
APP=(10.10.112.1 10.10.112.2 10.10.112.3 10.10.112.16 10.10.112.17 10.10.112.18 10.10.112.22)
for ADDR in ${APP[*]}
        do
         curl -u $LOGIN http://$ADDR:8080/cm5div6/api/dropcache
        done
echo "Dropcache all done"