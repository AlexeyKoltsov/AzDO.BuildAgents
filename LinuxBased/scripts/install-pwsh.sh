#! /bin/bash
# https://docs.microsoft.com/ru-ru/powershell/scripting/install/installing-powershell-core-on-linux

wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y powershell
