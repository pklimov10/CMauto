#!/bin/bash
config_home=/Users/pavelklimov/Downloads/РСХБ\ 3/
in_conf=/opt/conf
IPCMJ=127.0.0.1
PORTCMJ=5432
NAMECMJ=cmj
POOLCMJ=120
USERCMJ=postgres
PASSWDCMJ=password

IPCM5=127.0.0.1
PORTCM5=5432
NAMECM5=cm5
POOLCM5=120
USERCM5=cm5
PASSWDCM5=password

artemis1=127.0.0.1
artemis2=127.0.0.1

in=(SGO-SED-AP101
SGO-SED-AP102
SGO-SED-AP103
SGO-SED-AP104
SGO-SED-AP105
SGO-SED-AP106
SGO-SED-AP107
SGO-SED-AP108
SGO-SED-AP109
SGO-SED-VIP101
SGO-SED-MRM101
SGO-SED-MRM102
SGO-SED-TECH101
SGO-SED-TECH102
SGO-SED-REP101
SGO-SED-AP201
SGO-SED-AP202
SGO-SED-AP203
SGO-SED-AP204
SGO-SED-AP205
SGO-SED-AP206
SGO-SED-AP207
SGO-SED-AP208
SGO-SED-AP209
SGO-SED-VIP201
SGO-SED-MRM201
SGO-SED-MRM202
SGO-SED-TECH201
SGO-SED-TECH202
SGO-SED-REP201)


for ADDR in ${in[*]}
        do
         mkdir -p /$config_home/$ADDR
         cp $in_conf/* /$config_home/$ADDR
         sed -i 's/RENAME/'$ADDR'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/IPCMJRED/'$IPCMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/PORTCMJRED/'$PORTCMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/NAMECMJRED/'$NAMECMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/POOLCMJRED/'$POOLCMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/USERCMJRED/'$USERCMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/PASSWDCMJRED/'$PASSWDCMJ'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/IPCM5RED/'$IPCM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/PORTCM5RED/'$PORTCM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/NAMECM5RED/'$NAMECM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/POOLCM5RED/'$POOLCM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/USERCM5RED/'$USERCM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/PASSWDCM5RED/'$PASSWDCM5'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/brocker1/'$artemis1'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/brocker2/'$artemis2'/d' /$config_home/$ADDR/standalone.xml
         sed -i 's/RENAME/'$ADDR'/d' /$config_home/$ADDR/server.properties
        done
