[CmdletBinding()]
param(
    $BaseImage,
    $CustomImage,
    $CustomTag
)

if (-not $env:UserDNSDomain) {
    $Hostname = $env:ComputerName
}
else{
    $Hostname = "$env:ComputerName.$env:UserDNSDomain"
}

$FullCustomImage = "$Hostname/${CustomImage}:$CustomTag"

Write-Output "Building image:`n Image name: ${FullCustomImage}`n From: ${BaseImage}"
docker build -t "${FullCustomImage}" --build-arg baseImage=${BaseImage} -f Dockerfile .
docker tag "${FullCustomImage}" "${Hostname}/${CustomImage}:latest"