#! /bin/bash

HOSTNAME=$(hostname --fqdn | awk '{print tolower($0)}')

JSON=$(cat $1)
ORGS=$(cat ./../data/organizations.json)
ACCOUNT=$(echo ${JSON} | jq -r .AzDOaccount.accountname)
POOL=$(echo ${JSON} | jq -r .AzDOaccount.poolname)
TOKEN=$(echo ${ORGS} | jq -r .${ACCOUNT}.accesstoken)
AGENT=$(echo ${JSON} | jq -r .AzDOaccount.agentname)
IMAGE=$(echo ${JSON} | jq -r .image)

FULLCUSTOMIMAGE="${HOSTNAME}/${IMAGE}"
AGENTNAME="${AGENT}-${POOL}"
CONTAINERNAME=$(echo ${AGENTNAME} | awk '{print tolower($0)}')

echo -e "\n===================="
echo -e "Running image:\n Image name: ${FULLCUSTOMIMAGE}\n Agent name: ${AGENT}\n Pool: ${POOL}"
docker run -d \
    --name "${CONTAINERNAME}" \
    --restart=always \
    -e VSTS_ACCOUNT="${ACCOUNT}" \
    -e VSTS_POOL="${POOL}" \
    -e VSTS_TOKEN="${TOKEN}" \
    -e VSTS_AGENT="${AGENTNAME}" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    "${FULLCUSTOMIMAGE}"
