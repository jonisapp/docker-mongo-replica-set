docker image build \
--build-arg MONGO_IMAGE="mongo:${1:-4.4}" \
-f mongo-init/Dockerfile \
-t jonisapp/mongo_replicaset-init:mongo-${1:-4.4}1 \
--no-cache ./; \
docker image push jonisapp/mongo_replicaset-init:mongo-${1:-4.4}