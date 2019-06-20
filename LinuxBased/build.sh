#! /bin/bash

HOSTNAME=$(hostname --fqdn)
docker build -t "${HOSTNAME}/ubuntuhosted:latest" --build-arg baseImage=$1 -f Dockerfile .