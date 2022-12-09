#!/bin/bash

file_name=$(< /root/tmp/last_backup_name)

# Colors for outputs

BGreen='\033[1;32m'
BIRed='\033[1;91m'
IGreen='\033[0;92m'
Color_Off='\033[0m'

# download backup archive and md5 files

echo "Downloading ${file_name}.tar.gz..."

/usr/local/bin/aws --endpoint-url $ENDPOINT_URL s3 cp $BUCKET/${file_name}.tar.gz /root/tmp/restore/${file_name}.tar.gz
/usr/local/bin/aws --endpoint-url $ENDPOINT_URL s3 cp $BUCKET/${file_name}.md5 /root/tmp/restore/${file_name}.md5

# ------------------------------------ #
# check files integrity and restore DB #
# ------------------------------------ #

# integrity check

cd /root/tmp/restore
if md5sum --status -c ./${file_name}.md5; then
    echo -e "${IGreen}${file_name}.tar.gz integrity check status: OK.${Color_Off}"

    # unpacking

    if tar -zxvf /root/tmp/restore/${file_name}.tar.gz 1> /dev/null; then
        echo -e "${IGreen}${file_name}.tar.gz has been unpacked.${Color_Off}"

        # restore

        if mongorestore --host $MONGODB_HOST -u ${MONGODB_USER} -p ${MONGODB_PASS} --drop --verbose=1 /root/tmp/restore/dump; then
            echo -e "${BGreen}${file_name} has been successfully restored.${Color_Off}"

            # remove temp files

            rm -rf /root/tmp/restore/${file_name}.tar.gz /root/tmp/restore/dump
        else
            echo -e "${BIRed}${file_name} could not be restored.${Color_Off}"
        fi
    else
        echo -e "${BIRed}${file_name} could not be unpacked.${Color_Off}"
    fi

else
    echo -e "${BIRed}${file_name}.tar.gz integrity status: checksum did NOT match.${Color_Off}"
fi