#! /bin/bash
# https://docs.microsoft.com/ru-ru/powershell/scripting/install/installing-powershell-core-on-linux

apt-get install wget

VER=$(cat /etc/os-release | grep PRETTY_NAME | awk -F'=' '{print $2}' | tr -d '"')

if [[ "${VER}" =~ "GNU/Linux" ]]; then
    VERID=$(cat /etc/os-release | grep PRETTY_NAME | awk -F'=' '{print $2}' | sed 's/.* (\([[:alpha:]]*\))/\1/' | tr -d '"')
    printf "\nDetected Debian ${VERID}\n"
    apt-get update
    apt-get install -y curl apt-transport-https

    if [[ "${VER}" =~ "stretch" ]]; then
        apt-get install -y gnupg
    fi

    FEEDLINK="deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-${VERID}-prod ${VERID} main"
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    sh -c "echo ${FEEDLINK} > /etc/apt/sources.list.d/microsoft.list"
    apt-get update

elif [[ "${VER}" =~ "Ubuntu" ]]; then
    VERID=$(cat /etc/os-release | grep VERSION_ID | awk -F'=' '{print $2}' | tr -d '"') 
    printf "\nDetected Ubuntu ${VERID}\n"

    wget -q "https://packages.microsoft.com/config/ubuntu/${VERID}/packages-microsoft-prod.deb"
    dpkg -i packages-microsoft-prod.deb
    apt-get update
    if [ "${VERID}" == "18.04" ]; then add-apt-repository universe; fi
else
    echo "Couldn't detect your OS"
fi

apt-get install -y powershell