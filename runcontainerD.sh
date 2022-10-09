#!/usr/bin/bash
set -E
source <(curl -s https://raw.githubusercontent.com/rangapv/bash-source/main/s1.sh)

file1="/etc/containerd/config.toml"
configtoml (){
line2="\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.containerd\.runtimes\.runc\.options\]"
line3="\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true"

sedo1=`cat $file1 | grep "SystemdCgroup = false"`
sedo1s="$?"
sedo2=`cat $file1 | grep "SystemdCgroup = true"`
sedo2s="$?"
sedo3=`cat $file1 | grep "SystemdCgroup" -c`
sedo3s="$?"
if [[ (( $sedo1s -eq 0 )) ]]
then
sudo sed -ie 's/SystemdCgroup.*$/SystemdCgroup = true/g' $file1
fi
if [[ (( $sedo2s -ne 0 )) ]]
then
line2="\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.containerd\.runtimes\.runc\.options\]"
line3="\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true"
sudo sed -i "/$line2/a     $line3" $file1
fi
if [[ (( $sedo3 -gt 1 )) && (( $sedos -eq 0 )) ]]
then
	sudo gawk -i inplace '!a[$0]++' $file1
fi

echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
}


if [ ! -s "$file1" ]
then
	configtoml
fi

if [ -z "$mac" ]
then

if [ ! -z "$d1" ]
then
    if [ $ki = "debian" ]
    then
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
    configtoml 
    sudo systemctl restart containerd
    else	   
    echo "containerd is running at $check1"
    fi
    fi
elif [ ! -z "$s1" ]
then
    if [ $ki = "sles" ]
    then
    # sudo zypper install -y gcc make openssl-devel libffi-devel zlib-devel wget lsb-release
    count=1
    fi
    check1=`which containerd`
    check2=$(echo "$?")
    if [ $check2 -ne 0 ]
    then
     sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/SLE_15_SP2/Virtualization:containers.repo
     sudo zypper refresh
     sudo zypper install -y containerd
    else	    
    echo "containerd is running at $check1"
    fi
elif [ ! -z "$u1" ]
then
   if [ $ki = "ubuntu" ]
   then
   check1=`which containerd`
   check2=$(echo "$?")
   if [ $check2 -ne 0 ]
   then
   sudo $cm1 -y update
   sudo $cm1 install -y gnupg lsb-release apt-transport-https ca-certificates
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
   sudo $cm1 update
   sudo $cm1 install containerd.io
   sudo mkdir -p /etc/containerd
   containerd config default | sudo tee /etc/containerd/config.toml
   configtoml
   sudo systemctl restart containerd
   else
    echo "containerd is running at $check1"
   fi
   fi

fi


fi #end of Mac check

chkcont=`sudo systemctl status containerd`
chkconts="$?"
if [[ (( $chkconts -ne 0 )) ]]
then
	sudo systemctl start containerd
fi
