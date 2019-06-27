[CmdletBinding()]
param(
    $ParamsJSON
)
$Kind = "windows"

if (-not $env:UserDNSDomain) {
    $Hostname = $env:ComputerName
}
else {
    $Hostname = "$env:ComputerName.$env:UserDNSDomain"
}
$Hostname = $Hostname.ToLower()

# Getting paramaeters from json files
$JSONData = Get-Content $ParamsJSON | ConvertFrom-Json 
$Organizations = Get-Content "..\data\organizations.json" | ConvertFrom-Json
$JSONData = $JSONData | Where-Object kind -eq $Kind

$JSONData | % {
    $JSON = $_
    $Account = $JSON.AzDOaccount.accountname
    $Pool = $JSON.AzDOaccount.poolname
    $PoolSize = $JSON.AzDOaccount.poolsize
    $Token = $Organizations.$Account.accesstoken
    $Agent = $JSON.AzDOaccount.agentname
    $Image = $JSON.image

    $FullCustomImage = "${Hostname}/${Image}"
    if ($PoolSize -gt 1) {
        $AgentName = "${Agent}-${Pool}-{{NUM}}"
    }
    $ContainerName = $AgentName.ToLower()





    $ExpressionTpl = @"
        docker run -d ``
        --name "${ContainerName}" ``
        --restart=always ``
        -e AZP_URL="https://dev.azure/${Account}" ``
        -e AZP_POOL="${Pool}" ``
        -e AZP_TOKEN="${Token}" ``
        -e AZP_AGENT_NAME="${AgentName}" ``
        "${FullCustomImage}"
"@

    for ($i = 0; $i -lt $PoolSize ; $i++) {
        if ($i -lt 10) {
            $NumReplacer = "0$($i+1)"
        }
        else {
            $NumReplacer = "$($i+1)"
        }
        $Expression = $ExpressionTpl -replace "{{NUM}}", $NumReplacer

        Write-Output "`n===================="
        Write-Output "Running image:`n Image name: ${FullCustomImage}`n Agent name: ${AgentName}`n Pool: ${Pool}"
        Invoke-Expression $Expression
    }
}
