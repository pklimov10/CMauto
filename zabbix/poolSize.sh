#!/bin/bash
curl -u irshk:1 sgo-sed-tech101:8080/ssrv-war/af5-services/af5-server/info --silent  |jq '.components[2].info.invalidationInfo | .invalidationThreadPoolExecutorInfo' |grep poolSize |awk '{print $2}' | sed 's/,/ /g'
