#!/bin/bash
#Токен бота
TOKEN=
#id чата
CHAT_ID=
#утилита searcher-0.0.8.jar можно с путем /opt/searcher-0.0.8.jar
searcher=/opt/select/searcher-0.0.8.jar
#<путь до папки с файлом application.properties
properties=/opt/select/
#порт на котром запускаем утилиту (порт не должен быть занят)
port=6969
#куда сохраняем csv
my_dir_csv=/opt/select
#парметры формирования csv
#где objectType принимает 3 значения:
#rkk - если интересуют задачи / уведомления, созданные по РКК (адресация);
#resolution - задачи / уведомления, которые должны были быть созданы на основании резолюции (исполнение, контроль);
#all - и РКК, и резолюция.
objectType=resolution
#operation - принимает 3 значения:
#created - то есть задачи/уведомления, которые должны были быть созданы на основании факта создания или публикации документа;
#modified - задачи/уведомления, которые должны были быть созданы на основании факта редактирования списка адресатов (для РКК) или исполнителей и контроля (для резолюций);
#all - совокупность 1 и 2 пунктов.
operation=all
#формируем дату 1 день назад
dateFrom=$(date -d "1 day ago" +"%Y-%m-%d%%2000:00:00")
#Формируем дату сегодня -3 часа
dateTo=$(date +"%Y-%m-%d%%2000:00:00")
nameCSV=$(date +"%Y-%m-%d-%H-%M").csv
#опередляем джаву
#провряем путь до javahome systemctl status wildfly | grep Standalone  |awk '{print $2}'
my_java_home=`systemctl status wildfly | grep Standalone  |awk '{print $2}'`
#вормируем CSV
cd $properties
csv_dir=$my_dir_csv/$nameCSV
$my_java_home -jar $searcher --server.port=$port & sleep 40  && wget -P $my_dir_csv/ -O $nameCSV http://127.0.0.1:6969/search/absent/$objectType/$operation/$dateFrom/$dateTo -T 0
#убиваем java процес серчера
my_kill=$(ps -ef | grep java |grep $searcher |awk '{print $2}')
echo $my_kill
kill -9 $my_kill
curl -F chat_id=$CHAT_ID -F document=@"$csv_dir" -F caption="CSV" http://185.112.82.9:85/bot$TOKEN/sendDocument