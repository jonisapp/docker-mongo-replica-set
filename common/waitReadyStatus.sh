#!/bin/bash

function waitForDBNodeConnection() {
  until mongo --host ${1}_mongo-${2} --eval "printjson(db.runCommand({ serverStatus: 1}).ok)" &> /dev/null
    do
      sleep 1
    done
  
  echo -e "\033[0;92m${1}_mongo-${2} is ready.\033[0m"
}

for mongo_node in primary secondary-1 secondary-2
do
  waitForDBNodeConnection $COMPOSE_PROJECT_NAME $mongo_node &
done

wait