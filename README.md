# AzDO BuildAgents
I've created this project for myself to simplify my work, but I'll be very happy if it could help somebody else
Currently there is only support for Linux-based images.

Project from [Microsoft](https://hub.docker.com/_/microsoft-azure-pipelines-vsts-agent) describes the list of pre-builded Linux-agents which can be used to deploy. It's depricated for now, so I'm planning to move from it.


## Requerements
### Linux hosts
- [jq](https://stedolan.github.io/jq/)
- [git](https://git-scm.com)

## Steps to build a custom agent
First of all, if you'd like to deploy custom build agent, you have to build your custom image. This small script example will help you pull the code and start:

```bash
git clone https://github.com/AlexeyKoltsov/AzDO.BuildAgents.git
cd AzDO.BuildAgents && git checkout master
cd LinuxBased && chmod +x build.sh run.sh
/bin/bash -c "./build.sh mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04-docker-18.06.1-ce ubuntu-16.04"
```
* Here we're using **vsts-agent:ubuntu-16.04-docker-18.06.1-ce** as the base image
* Our final image will be named as **ubuntu-16.04**
* The name of repository will be appended to the image name automatically during buildtime (your host's fqdn)

At this moment **az cli**, **powershell core** and **AzCopy** are being installed during building, but nothing can stop you from adding custom install scripts under the */scripts* directory and adding install command to the *Dockerfile*

## Steps to run a custom agent

1. Prepare your Azure DevOps organization description based on the **organizations_template.json**, and name it **organizations.json** and place under the **data** folder, f.e.:
```json
{
    "MyLovelyOrg": {
        "accountname": "bigbusinesscorp",
        "accesstoken": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
}
```
Make a note:
* _MyLovelyOrg_ is a name of your org settings, which you will reference in __params-*__ files
* _bigbusinesscorp_ is the actual name of your AzDO account
* _accesstoken_ is PAT, generated to [authenticate build agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat)


2. Prepare a custom parameters file based on the **params_template.json**, name it f.e. **params-MyConfig.json** and place under the **data** folder. It will help you not to push your data to source code, f.e.:
```json
{
    "image": "ubuntu-16.04",
    "AzDOaccount": {
        "accountname": "MyLovelyOrg",
        "poolname": "Default",
        "agentname": "Ubuntu_16.04"
 }
}
```
Make a note:
* You're using here _MyLovelyOrg_ as a reference to the entry in __organizations.json__
* _ubuntu-16.04_ is the existing image on your host. 
* The name of repository will be appended to the image name automatically during runtime (your host's fqdn)


3. Run agent: 
```bash
/bin/bash -c "./run.sh  ./../data/params-MyConfig.json"
```
* This command will run a new container based on parameters in the _params-MyConfig.json_ file
