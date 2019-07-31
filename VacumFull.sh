#!/bin/bash
#1) отсановка серверов +
#2) создание бекапа +
#3) Вакум фулл +
#4) запуск системы +
#5) Провека отставание кластера
#6) Если необходимо то востанавлваем кластер
#7) a)Оставналиваем ситсему
#   б)Востанавливаем кластер
#   в)Запускаем систему проверяем
#Токен бота
TOKEN=
#id чата
CHAT_ID=
URL="http://185.112.82.9:85/bot$TOKEN/sendMessage"
#Деректория для бекапов СУБД
bacup_dir=/pgdata/backup
#Имя базы для CM5
db_nameCM5=cm5
#Имя базы для CMJ
db_nameCMJ=cmj
#Список серорв апп для откобчения
APP=(10.10.112.1 10.10.112.2 10.10.112.3 10.10.112.16 10.10.112.17 10.10.112.18 10.10.112.22)
#IP тех сервера
APP1=10.10.112.1
#Учетка для проверки
LOGIN=login:pass
#Отключение APP
for ADDR in ${APP[*]}
        do
         ssh $ADDR "systemctl stop wildfly*"
        done
#Создание бекапов базы
sudo -u postgres pg_dump --port 5432 --username "postgres" --role "postgres" --format directory --blobs --no-privileges --no-tablespaces --verbose --no-unlogged-table-data --jobs=10 --file "$bacup_dir/$(date -d "today" +"%Y-%m-%d-%H-%M-cm5")" "$db_nameCM5"
sudo -u postgres pg_dump --port 5432 --username "postgres" --role "postgres" --format directory --blobs --no-privileges --no-tablespaces --verbose --no-unlogged-table-data --jobs=10 --file "$bacup_dir/$(date -d "today" +"%Y-%m-%d-%H-%M-cmj")" "$db_nameCMJ"
#Запуск вакум
psql -U postgres -d $db_nameCM5 -c 'VACUUM FULL ANALYZE;'
psql -U postgres -d $db_nameCMJ -c 'VACUUM FULL ANALYZE;'
#ЗАпуск Апп серверов
ssh $APP1 'systemctl start wildfly'
ping -c 850 127.0.0.1
if curl -u $LOGIN $app1 -m 10 |grep 8080
then
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Сервер успешно запущен"
APP_Target=(10.10.112.2 10.10.112.3 10.10.112.16 10.10.112.17 10.10.112.18 10.10.112.22)
for APP_user in ${APP_Targe[*]}
        do
         ssh $APP_user "systemctl start wildfly*"
        done
else
A=$(date)
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Сервер не запущен"
exit
fi
#Проверка кластера
sudo -u postgres createdb $(date -d "today" +"%Y-%m-%d-%H")

