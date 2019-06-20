#! /bin/bash

HOSTNAME=$(hostname --fqdn | awk '{print tolower($0)}')

JSON=$(cat $1)
ACCOUNT=$(echo ${JSON} | jq -r .AzDOaccount.accountname)
POOL=$(echo ${JSON} | jq -r .AzDOaccount.poolname)
TOKEN=$(echo ${JSON} | jq -r .AzDOaccount.accesstoken)
AGENT=$(echo ${JSON} | jq -r .AzDOaccount.agentname)
IMAGE=$(echo ${JSON} | jq -r .image)

FULLCUSTOMIMAGE="${HOSTNAME}/${IMAGE}"
echo "\n===================="
echo -e "Running image:\n Image name: ${FULLCUSTOMIMAGE}\n Agent name: ${AGENT}\n Pool: ${POOL}"
docker run -d \
    -e VSTS_ACCOUNT=${ACCOUNT} \
    -e VSTS_POOL=${POOL} \
    -e VSTS_TOKEN=${TOKEN} \
    -e VSTS_AGENT=${AGENT} \
    -v /var/run/docker.sock:/var/run/docker.sock \
    "${HOSTNAME}/${IMAGE}"
