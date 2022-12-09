#!/bin/bash

# Colors for outputs

BGreen='\033[1;32m'
Yellow='\033[0;93m'
BIRed='\033[1;91m'
Color_Off='\033[0m'

# Wait until all db instances are initialized

/root/waitReadyStatus.sh

# Create a 3-members replica set

mongo --host ${COMPOSE_PROJECT_NAME}_mongo-primary:27017 -u ${MONGODB_USER} -p ${MONGODB_PASS} --quiet <<EOF
config = {
  "_id" : "${COMPOSE_PROJECT_NAME}_replica-set",
  "members" : [
    {
      "_id" : 0,
      "host" : "${COMPOSE_PROJECT_NAME}_mongo-primary:27017",
      "priority": 5
    },
    {
      "_id" : 1,
      "host" : "${COMPOSE_PROJECT_NAME}_mongo-secondary-1:27017",
      "priority": 1
    },
    {
      "_id" : 2,
      "host" : "${COMPOSE_PROJECT_NAME}_mongo-secondary-2:27017",
      "priority": 1
    },
  ]
};
rs.initiate(config);

db.enableFreeMonitoring();
EOF

echo -e "\n"

if [[ -v MONGO_IMPORT_DB_URL && ! -d "/tmp/mongo_restore/dump" ]]; then
  echo 'Downloading initial database...'
  mongodump --uri $MONGO_IMPORT_DB_URL -o /tmp/mongo_restore/dump 1> /dev/null
  echo 'Importing initial database...'
  mongorestore --host ${COMPOSE_PROJECT_NAME}_mongo-primary:27017 -u ${MONGODB_USER} -p ${MONGODB_PASS} /tmp/mongo_restore/dump
else
  if [[ -d "/tmp/mongo_restore/dump" ]]; then
    echo -e "${Yellow}${COMPOSE_PROJECT_NAME} database has already been imported. To reimport, you must manually delete /tmp/mongo_restore/dump and redeploy.${Color_Off}\n"
  fi
fi

echo -e "${BGreen}Mongodb replica set initialisation successful!${Color_Off}\n"

sleep 10

echo -e "\n${BIRed}****************************** Free monitoring URL ******************************${Color_Off}\n"
mongo --host ${COMPOSE_PROJECT_NAME}_mongo-primary:27017 -u ${MONGODB_USER} -p ${MONGODB_PASS} --quiet <<EOF
  db.getFreeMonitoringStatus().url
EOF
echo -e "\n${BIRed}*********************************************************************************${Color_Off}\n"