# AzDO BuildAgents

## Steps to build a custom agent
``` bash
git clone https://github.com/AlexeyKoltsov/AzDO.BuildAgents.git
cd AzDO.BuildAgents && git checkout develop
cd LinuxBased && chmod +x build.sh run.sh
/bin/bash -c "./build.sh mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04-docker-18.06.1-ce ubuntu-16.04"
```
## Steps to run a custom agent



- Prepare a custom parameters file based on the **params_template.json** and name it f.e. __params-MyConfig.json__

- Run agent: 
``` bash
/bin/bash -c "./run.sh params-MyConfig.json"
```
