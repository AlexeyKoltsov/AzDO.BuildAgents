#! /bin/bash

HOSTNAME=$(hostname --fqdn | awk '{print tolower($0)}')

BASEIMAGE=$1
CUSTOMIMAGE=$2
#CUSTOMTAG=$(echo "${BASEIMAGE}" | awk -F ':' '{print $2}')
CUSTOMTAG="latest"

FULLCUSTOMIMAGE="${HOSTNAME}/${CUSTOMIMAGE}:${CUSTOMTAG}"
echo -e "Building image:\n Image name: ${FULLCUSTOMIMAGE}\n From: ${BASEIMAGE}"
docker build -t "${FULLCUSTOMIMAGE}" --build-arg baseImage=${BASEIMAGE} -f Dockerfile .