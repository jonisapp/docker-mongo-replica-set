docker image build \
--build-arg MONGO_IMAGE="mongo:${1:-4.4}" \
-f backup/Dockerfile \
-t jonisapp/mongo-backup_s3-compatible-storage:mongo-${1:-4.4} \
--no-cache ./; \
docker image push jonisapp/mongo-backup_s3-compatible-storage:mongo-${1:-4.4}