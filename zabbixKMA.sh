#!/bin/bash
UserParameter=AgentStructLoader[*], "$1"psql -qtAX -p "$2" -U "$3" -d "$4" -f "/Users/pavelklimov/PycharmProjects/DockerCM62Full/AgentStructLoader.sql"

#логин пользователя
login=irshk
pass=1
#Урл сервера
url=sgo-sed-tech101
port=8080


#записываем временый результат
curl -u $login:$pass $url:$port/ssrv-war/af5-services/globalcache/ping/1000 --silent

