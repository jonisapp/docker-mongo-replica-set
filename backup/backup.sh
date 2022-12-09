#!/bin/bash

file_name="${COMPOSE_PROJECT_NAME}_backup_$(date +"%y-%m-%d-%H%M")"

# Colors for outputs

BGreen='\033[1;32m'
Color_Off='\033[0m'

# -------------------------------------------------- #
# dump, archive and upload to S3-compatible endpoint #
# -------------------------------------------------- #

# dump and archive db
echo "${file_name}: archiving..."

mongodump -h $MONGODB_HOST -u $MONGODB_USER -p $MONGODB_PASS --out /root/tmp/backup/dump 1> /dev/null
cd /root/tmp/backup
tar -czvf ${file_name}.tar.gz dump 1> /dev/null

# md5 creation

md5sum ./${file_name}.tar.gz > ./${file_name}.md5

# upload to s3 storage
echo "${file_name}: Uploading..."

/usr/local/bin/aws --endpoint-url $ENDPOINT_URL s3 cp /root/tmp/backup/${file_name}.tar.gz $BUCKET/${file_name}.tar.gz
/usr/local/bin/aws --endpoint-url $ENDPOINT_URL s3 cp /root/tmp/backup/${file_name}.md5 $BUCKET/${file_name}.md5

# update last backup name

echo "$file_name" > /root/tmp/last_backup_name

# remove temp files

rm -rf /root/tmp/backup/dump /root/tmp/backup/${file_name}.tar.gz /root/tmp/backup/${file_name}.md5

echo -e "${BGreen}${file_name} successfully archived!${Color_Off}"