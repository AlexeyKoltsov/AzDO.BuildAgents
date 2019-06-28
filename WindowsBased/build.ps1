[CmdletBinding(DefaultParameterSetName="JSON")]
param(
    [Parameter(Mandatory=$true,ParameterSetName="TextInput")]
        [string]$BaseImage,
    [Parameter(Mandatory=$true,ParameterSetName="TextInput")]
        [string]$CustomImageName,
    [Parameter(ParameterSetName="TextInput")]
        [string]$Hostname,
    [Parameter(ParameterSetName="TextInput")]
        [string]$CustomTag,

    [Parameter(ParameterSetName="JSON")]
        [string]$ParamsJSON
)

# Parameters has been inputed manually
if ($PsCmdlet.ParameterSetName -eq "TextInput") {

}
elseif ($PsCmdlet.ParameterSetName -eq "JSON") {
    $InputParams = Get-Content $ParamsJSON | ConvertFrom-Json

    $BaseImage = $InputParams.baseimage
    $Hostname = $InputParams.hostname
    $CustomImageName = $InputParams.customimagename
    $CustomTag = $InputParams.customimagetag

    if(-not $BaseImage){ throw "BaseImage is not defined" }
    if(-not $CustomImageName){ throw "CustomImageName is not defined" }

}
else {
    throw "Unsupported parameter set used"
}

if (-not $CustomTag) {
    $CustomTag = "latest"
}
if (-not $Hostname) {
    if (-not $env:UserDNSDomain) {
        if (-not $env:ComputerName) {
            $Hostname = (hostname --fqdn)
        }
        $Hostname = $env:ComputerName
    }
    else{
        $Hostname = "$env:ComputerName.$env:UserDNSDomain"
    }
}
$Hostname = $Hostname.ToLower()

$FullCustomImageName = "$Hostname/${CustomImageName}:$CustomTag"

Write-Output "Building image:`n Image name: ${FullCustomImageName}`n From: ${BaseImage}"
docker build -t "${FullCustomImageName}" --build-arg baseImage=${BaseImage} -f Dockerfile .
if ($CustomTag -ne "latest") {
    docker tag "${FullCustomImageName}" "${Hostname}/${CustomImageName}:latest"
}