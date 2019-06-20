# AzDO BuildAgents

## Some steps to build a custom agent
git clone https://github.com/AlexeyKoltsov/AzDO.BuildAgents.git

cd AzDO.BuildAgents && git checkout develop

cd LinuxBased && chmod +x build.sh

 /bin/bash -c "./build.sh mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04-docker-18.06.1-ce"
