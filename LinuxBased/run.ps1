[CmdletBinding()]
param(
        [string]$ParamsJSON,
        [switch]$Override
)

function Remove-DockerContainer {
    param (
        [string]$Hash
    )
    [void] ((docker stop $Hash) -and (docker rm $Hash))
}

#At this time supports only requests without body
function Invoke-AzDOApi {
    param (
        [string]$APIver = "api-version=5.1-preview.1",
        [string]$Account = $script:Account,
        [string]$Token = $script:Token,
        [string]$Method,
        [string]$Uri
    )
    $Tokenbase64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$Token)))

    Invoke-RestMethod -Method $Method -Uri $Uri -Headers @{Authorization=("Basic {0}" -f $Tokenbase64AuthInfo)}
}

function Remove-AzDOAgent {
    param (
        [string]$AgentName
    )
    $BaseAPIURI = "https://dev.azure.com/$Account/_apis"

    #Getting ID of the Pool
    $URIPool = "${BaseAPIURI}/distributedtask/pools?poolName=${script:Pool}&${APIver}"
    $poolid = (Invoke-AzDOApi -Method Get -Uri $URIPool).value.id

    #Getting ID of the Agent
    $URIAgent = "$BaseAPIURI/distributedtask/pools/${poolid}/agents?agentName=${AgentName}&${APIver}"
    $agentId = (Invoke-AzDOApi -Method Get -Uri $URIAgent).value.id

    #Deleting the agent
    $URIDelete = "$BaseAPIURI/distributedtask/pools/${poolid}/agents/${agentId}?$APIver"
    Invoke-AzDOApi -Method Delete -Uri $URIDelete
}

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
    $AgentNameFamily = "${Agent}-${Pool}"
    $ContainerNameFamily = $AgentNameFamily.ToLower()

    $ExpressionTpl = @"
        docker run -d ``
        --name "${ContainerNameFamily}-{{num}}" ``
        --restart=always ``
        -e AZP_URL="https://dev.azure.com/${Account}" ``
        -e AZP_POOL="${Pool}" ``
        -e AZP_TOKEN="${Token}" ``
        -e AZP_AGENT_NAME="${AgentNameFamily}-{{num}}" ``
        -v /var/run/docker.sock:/var/run/docker.sock ``
        "${FullCustomImage}"
"@

    $ExistingContainers = @()
    $ExistingContainersRaw = $((docker ps -a -f name=$ContainerNameFamily --format '{{.ID}};{{.Image}};{{.Status}};{{.Names}}'))
    $ExistingContainersRaw |%{
        $item = $_ -split ';'
        $ExistingContainers += [PSCustomObject]@{
            hash = $item[0]
            image = $item[1]
            status = $item[2]
            name = $item[3]
        }
    }

    if ($ExistingContainers.Count -gt $PoolSize) {
        $MaxIter = $ExistingContainers.Count       
    }
    else{
        $MaxIter = $PoolSize
    }

    for ($i = 1; $i -le $MaxIter ; $i++) {
        if ($i -lt 10) {
            $NumReplacer = "0$i"
        }
        else {
            $NumReplacer = "$i"
        }

        $ContainerNameCurrent = "${ContainerNameFamily}-${NumReplacer}"
        $ExistingContainer = $ExistingContainers | Where name -EQ $ContainerNameCurrent

        # This agent has to be removed as it exceeds the pool size
        if ($i -gt $PoolSize) {
            Write-Output "Removing exceeding pool size container $($ExistingContainer.name)"
            Remove-DockerContainer -Hash $ExistingContainer.hash
            Remove-AzDOAgent -AgentName $ExistingContainer.name
            continue
        }
        
        if ($ExistingContainer) {
            if ($Override) {
                Write-Output "Overriding $($ExistingContainer.name)"
                Remove-DockerContainer -Hash $ExistingContainer.hash
                Remove-AzDOAgent -AgentName $ExistingContainer.name

            }
            else{
                Write-Output "Comtainer $($ExistingContainer.name) is already running"
                continue
            }
            
        }

        $Expression = $ExpressionTpl -replace "{{num}}", $NumReplacer

        Write-Output "`n===================="
        Write-Output "Running image:`n Image name: ${FullCustomImage}`n Agent name: ${ContainerNameReplaced}`n Pool: ${Pool}"
        Invoke-Expression $Expression
    }
}
