#!/bin/bash
#my_java_home
#JDBCFILELOCATION
conf=/Users/pavelklimov/PycharmProjects/CMauto/1/
alldb=`ls $conf`

# проверка существования каталога
if [ -e $conf ];
then
echo "Каталог $conf существует. Проверим наличие файлов"
fi
# проверка существования файла
if [ `ls $conf | wc -l` -eq 0 ]
  then
    echo "нету сохраненых конфигураций для РБД"
    echo "Хотите ли вы создать создать кофнгурацию для РБД (y/n)"
    read item
    case "$item" in
        y|Y) echo "Ввели «y», продолжаем..."
            ;;
        n|N) echo "Ввели «n», завершаем..."
            exit 0
            ;;
        *) echo "Ничего не ввели. Выполняем действие по умолчанию..."
            ;;
    esac
    read -p 'Названиее конфига без проблеов на латинице напримеер CM5QA: ' nameBD
    read -p 'IP сервера БД: ' IPBD
    read -p 'Порт сеервера БД: ' PORTBD
    read -p 'Username БД: ' UsernameBD
    read -p 'Пароль БД: ' BDpassword
    read -p 'Названиее базы: ' DBnamee

      APP=($IPBD $PORTBD $UsernameBD $BDpassword)
        for ADDR in ${APP[*]}
          do
        echo $ADDR
        echo $ADDR >> $conf/$nameBD
      done
echo $dbconect
  else
alldb=`ls $conf`
    echo  "Выбирите базу для подключеения:"
    echo $alldb
    read item
    cat $conf/$item
    IPBD=`cat $conf/$item |grep "IPBD" | sed  's/=/ /g; s/"/ /g' |awk '{print $2}'`
    PORTBD=`cat $conf/$item |grep "PORTBD" | sed  's/=/ /g; s/"/ /g' |awk '{print $2}'`
    UsernameBD=`cat $conf/$item |grep "UsernameBD" | sed  's/=/ /g; s/"/ /g' |awk '{print $2}'`
    BDpassword=`cat $conf/$item |grep "BDpassword" | sed  's/=/ /g; s/"/ /g' |awk '{print $2}'`
    DBnamee=`cat $conf/$item |grep "DBnamee" | sed  's/=/ /g; s/"/ /g' |awk '{print $2}'`
fi
APP=(IPBD PORTBD UsernameBD BDpassword DBnamee)
        for ADDR in ${APP[*]}
          do
        echo $ADDR
      done
echo "Подключеение выполнеено к базе" $DB_CN5_NAME

echo "Press [CTRL+C] to exit this loop..."
while true
do

    echo "Введитее ваш SQL запрос"
    read $qvery
    $my_java_home -cp $JDBCFILELOCATION":/"  PostgresqlQueryExecuteJDBC  -h $IP_CM5 -p $PORT_CM5 -U $DB_CM5_USER -W $DB_CM5_PASS -d $DB_CN5_NAME -c "$qvery"


   if [ condition ]

   then

       break

   fi

done