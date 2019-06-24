#! /bin/bash

HOSTNAME=$(hostname --fqdn | awk '{print tolower($0)}')

BASEIMAGE=$1
CUSTOMIMAGE=$2

if [ -z "$3" ]; then
    CUSTOMTAG="latest"
else
    CUSTOMTAG=$3
fi

FULLCUSTOMIMAGE="${HOSTNAME}/${CUSTOMIMAGE}:${CUSTOMTAG}"
echo -e "Building image:\n Image name: ${FULLCUSTOMIMAGE}\n From: ${BASEIMAGE}"
docker build -t "${FULLCUSTOMIMAGE}" --build-arg baseImage=${BASEIMAGE} -f Dockerfile .
docker tag "${FULLCUSTOMIMAGE}"  "${HOSTNAME}/${CUSTOMIMAGE}:latest"