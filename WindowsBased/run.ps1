[CmdletBinding()]
param(
    $ParamsJSON
)

if (-not $env:UserDNSDomain) {
    $Hostname = $env:ComputerName
}
else{
    $Hostname = "$env:ComputerName.$env:UserDNSDomain"
}


# Getting paramaeters from json files
$JSON = Get-Content $ParamsJSON | ConvertFrom-Json
$Organizations = Get-Content ".\..\data\organizations.json" | ConvertFrom-Json
$Account = $JSON.AzDOaccount.accountname
$Pool = $JSON.AzDOaccount.poolname
$Token = $Organizations.$Account.accesstoken
$Agent = $JSON.AzDOaccount.agentname
$Image = $JSON.image

$FullCustomImage = "${Hostname}/${Image}"
$AgentName = "${Agent}-${Pool}"
$ContainerName = $AgentName.ToLower()
