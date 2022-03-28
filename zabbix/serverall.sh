#!/bin/bash
#логин пользователя
login=irshk
pass=1
#Урл сервера
url=sgo-sed-tech101
port=8080
curl -u $login:$pass $url:$port/ssrv-war/af5-services/globalcache/ping/1000 --silent |jq '.nodeInfos[] | .nodeName' |sed 's/"/ /;s/\"/ /g' |wc -l