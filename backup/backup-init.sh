#!/bin/bash

# Wait until all db instances are initialized

/root/waitReadyStatus.sh

# restore db if BACKUP_AUTO_RESTORE env var is set

if [ $BACKUP_AUTO_RESTORE == true ]; then
  /root/restore-last.sh
fi

# ------------------------------ #
# set crontab job and start cron #
# ------------------------------ #

# Exporting env to backup_env.sh file
printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' > /root/backup_env.sh

echo "${CRON_TIME} . /root/backup_env.sh; /root/backup.sh >> /root/backup.log" > /etc/cron.d/backup_job
chmod u+x /etc/cron.d/backup_job
crontab /etc/cron.d/backup_job
crontab -l

# start cron in foreground mode

cron -L 4 && tail -f /root/backup.log