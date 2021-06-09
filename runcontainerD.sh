#!/usr/bin/bash
set -E
li=$(uname -s)

if [ $(echo $li | grep Linux) ]
then
	mac=""
else
	mac=$(sw_vers | grep Mac)
fi

d1=$(cat /etc/*-release | grep ID= | grep debian)

if [ -z "$mac" ]
then
        
	echo "It is a Linux Box" 

else
	echo "It is a Mac"

fi


if [ ! -z "$d1" ]
then
    ji=$(cat /etc/*-release | grep ^ID= | grep -v "\"" | awk '{split($0,a,"=");print a[2]}') 
    ki="${ji,,}"
    if [ $ki = "debian" ]
    then
     echo "It is Debian"
    fi
    check1=`which containerd`
    check2=$(echo "$?")
    if [ $check2 -ne 0 ]
    then
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y install gnupg 
    curl -fsSl https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo "deb [arch=64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt -y install containerd
    sudo systemctl restart containerd


    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo systemctl restart containerd
    else	    
    echo "containerd is running at $check1"
    fi

fi