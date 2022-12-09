ARG MONGO_IMAGE=mongo:4.4

FROM $MONGO_IMAGE AS deps

WORKDIR /root

# curl, unzip and cron installs

RUN apt-get update
RUN apt-get install cron curl unzip

# awscli install

ADD "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" ./awscliv2.zip
RUN unzip ./awscliv2.zip 
RUN ./aws/install
RUN rm -rf /root/awscliv2.zip aws

FROM deps AS runner

# copy backup and backup-init scripts

COPY ./backup/backup-init.sh /root/backup-init.sh
COPY ./common/waitReadyStatus.sh /root/waitReadyStatus.sh
COPY ./backup/backup.sh /root/backup.sh
COPY ./backup/restore-last.sh /root/restore-last.sh
RUN chmod u+x /root/waitReadyStatus.sh
RUN chmod u+x /root/backup.sh
RUN chmod u+x /root/restore-last.sh

# set backup job

RUN touch backup.log

ENTRYPOINT ["bash", "/root/backup-init.sh"]
