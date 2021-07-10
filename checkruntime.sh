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
dk1=$?
dks=$(sudo systemctl status $k 2>&1 > /dev/null)
dks1=$?
#dksd=`ps -ef |grep $k |grep -v grep | wc -l`
dksd=`ps -ef | grep containerd | grep -v grep | awk '{split($0,a," "); if (a[8]~/containerd/) print $0}' | wc -l`
#echo "dks1 is $dks1"
if [[ (( $dk1 -ne 0 )) ]]
then
	dk1=5
fi
if [[ (( $dks1 -ne 0 )) ]]
then
	dks1=5
fi
if [[ (( $dksd -eq 0 )) ]]
then
       (( dks1=$dks1+5 ))
fi
#temp1="$k[$dk1]=$dks1"
#echo "temp1 is $temp1"
if [[ $k = "containerd" ]]
then
	containerd[$dk1]=$dks1
elif [[ $k = "dockerd" ]]
then
       dockerd[$dk1]=$dks1
fi

done
}


rncd() {

for key in "${!dockerd[@]}"; do
    rund=$(( $key + ${dockerd[$key]} ))
    if [[ (( $key -eq 0 )) && (( $rund -gt 5 )) ]]
    then
      echo "The container runtime is Dockerd and it is not running"
      DFlag=1
      drun=1
      Flag=1
    elif  [[ (( $key -eq 0 )) && (( $rund -eq 0 )) ]]
    then
      echo "The container runtime is Dockerd and it is running"
      DFlag=1
      drun=1
      Flag=1
    fi
done
for key in "${!containerd[@]}"; do
    runc=$(( $key + ${containerd[$key]} ))
    if [[ (( $key -eq 0 )) && (( $runc -gt 5 )) && (( $DFlag -lt 1 )) ]]
    then
      echo "The container runtime is Containerd and it is not running"
      Flag=1
      crun=1
    elif  [[ (( $key -eq 0 )) && (( $runc -eq 0 )) && (( $DFlag -lt 1 )) ]]
    then
      echo "The container runtime is Containerd and it is running"
      Flag=1
      crun=1
    fi
done
if [[ (( $crun -eq 0 )) && (( $drun -eq 0 )) ]]
then
echo "No Container compatible runtime"
fi
}



runc1=( dockerd containerd)
kuberun "${runc1[@]}"
rncd
