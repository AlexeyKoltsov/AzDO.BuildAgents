[CmdletBinding()]
param(
        [string]$ParamsJSON,
        [switch]$Override
)
$Kind = "linux"

if (-not $Hostname) {
    if (-not $env:UserDNSDomain) {
        if (-not $env:ComputerName) {
            $HostnameRaw = (hostname --fqdn)
        }
        else {
            $HostnameRaw = $env:ComputerName 
        }       
    }
    else{
        $HostnameRaw = "$env:ComputerName.$env:UserDNSDomain"
    }
    $Hostname = $HostnameRaw.ToLower()
}

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
    $AgentName = "${Agent}-${Pool}-{{num}}"
    $ContainerName = $AgentName.ToLower()

    $ExpressionTpl = @"
        docker run -d ``
        --name "${ContainerName}" ``
        --restart=always ``
        -e AZP_URL="https://dev.azure.com/${Account}" ``
        -e AZP_POOL="${Pool}" ``
        -e AZP_TOKEN="${Token}" ``
        -e AZP_AGENT_NAME="${AgentName}" ``
        -v /var/run/docker.sock:/var/run/docker.sock ``
        "${FullCustomImage}"
"@

    for ($i = 0; $i -lt $PoolSize ; $i++) {
        if ($i -lt 10) {
            $NumReplacer = "0$($i+1)"
        }
        else {
            $NumReplacer = "$($i+1)"
        }
        $Expression = $ExpressionTpl -replace "{{num}}", $NumReplacer

        $ContainerNameReplaced = $ContainerName -replace "{{num}}", $NumReplacer
        $ExistingContainer = $((docker ps -f name=$ContainerNameReplaced))[1] -replace '\s{2,}', '__' -split '__'

        if ($ExistingContainer.Length -gt 1) {
            if ($Override) {
                Write-Output "Overriding $($ExistingContainer[5])"
                $hash = $ExistingContainer[0]
                [void] (docker stop $hash)
                [void] (docker rm $hash)
            }
            else{
                Write-Output "Comtainer $($ExistingContainer[5]) is already running"
                continue
            }
            
        }

        Write-Output "`n===================="
        Write-Output "Running image:`n Image name: ${FullCustomImage}`n Agent name: ${AgentName}`n Pool: ${Pool}"
        Invoke-Expression $Expression
    }
}
