#!/bin/bash
#1) Выполняем запрос
#2) Если не ноль то выполняем апдейт
#3) Выполняем опять селект
#4) Присылаем результаты телеграм файлом
#Токен бота
TOKEN=
#id чата
CHAT_ID=
URL="http://185.112.82.9:85/bot$TOKEN/sendMessage"

today=$(date +'%Y-%m-%d')

a=`psql -U postgres -t -d cm5 -c \ "select count(*) from ag_data_message where ag_data_message.agent=25 and (created_date>'$today' and created_date<'$today')";`
if [ "$a" -gt "0" ]
then
  curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Обнаружены зависшие задачи выполняем update"
  psql -U postgres -t -d cm5 -c \ "update ag_data_message set processing=0 where ag_data_message.agent=25 and (created_date>'$today' and created_date<'$today' and excluded=0 )";
  b=`psql -U postgres -t -d cm5 -c \ "select count(*) from ag_data_message where ag_data_message.agent=25 and (created_date>'$today' and created_date<'$today')";`
    if [ "$b" -gt "0" ]
    then
      curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Задачи не удалилсь"
      curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Собираю данные"
      infoCSV=`psql -U postgres -x -d cm5 -c \ "select * from ag_data_message where ag_data_message.agent=25 and (created_date>'$today' and created_date<'$today')";`
      echo $infoCSV > /opt/$(date +'%Y-%m-%d').csv
      curl -F chat_id=$CHAT_ID -F document=@"/opt/$(date +'%Y-%m-%d').csv" -F caption="CSV" http://185.112.82.9:85/bot$TOKEN/sendDocument
        else
          curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="Успешно"
    fi
  else
    echo $a
fi