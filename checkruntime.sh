#!/bin/bash
set -E
declare -A dockerd
declare -A containerd
runc=0
rund=0
Flag=0
DFlag=0
crun=0
drun=0

kuberun() {
arrayk=("$@")
dk=0
dks=0
dk1=0
dks1=0

for k in ${arrayk[@]}
do
dk=$(which $k)
dk1="$?"
temp1="$k"
dks=$(sudo systemctl status $k) 
dks1="$?"

if [[ ( $dk1 -ne 0 ) ]]
then
	dk1=5
fi
if [[ ( $dks1 -ne 0 ) ]]
then
	dks1=5
fi
"$k"[$dk1]=$dks1
if [[ $k = "containerd" ]]
then
	containerd[$dk1]=$dks1
elif [[ $k = "dockerd" ]]
then
       dockerd[$dk1]=$dks1
fi

done
}


runchek() {
r1=`ps -ef |grep dockerd | grep -v grep | grep containerd | wc -l`
if [[ ( $r1 -eq 1 ) ]]
then
	echo "The kubelet is using the \"dockerd\" as runtime"
        DFlag=1
fi

}
rncd() {

for key in "${!dockerd[@]}"; do
    echo "$key ${dockerd[$key]}"
    rund=$(( $key + ${dockerd[$key]} ))
done
for key in "${!containerd[@]}"; do
    echo "$key ${containerd[$key]}"
    runc=$(( $key + ${containerd[$key]} ))
done
}



runc1=( dockerd containerd)
kuberun "${runc1[@]}"
rncd
runchek

if [[ $runc -eq 0 && $DFlag -eq 0 ]]
then
	echo "The runtime is Containerd and it is up-and running"
        Flag=1
	crun=1
elif [[ $rund -ge 0 && $DFlag -eq 1 ]]
then
	echo "The runtime is Docker and it is up-and running"
	Flag=1
	drun=1
else
	echo "There are no Kubernetes compatible runtime on this box pls install containerd or dockerd"
fi

