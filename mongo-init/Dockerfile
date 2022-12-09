ARG MONGO_IMAGE=mongo:4.4

FROM $MONGO_IMAGE

WORKDIR /root

COPY ./mongo-init/mongo-init.sh /root/mongo-init.sh
COPY ./common/waitReadyStatus.sh /root/waitReadyStatus.sh
RUN chmod u+x /root/waitReadyStatus.sh

ENTRYPOINT ["bash", "/root/mongo-init.sh"]