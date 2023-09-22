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
cnrun=0
dnrun=0

kuberun() {
arrayk=("$@")
dk=0
dks=0
dk1=0
dks1=0

for k in ${arrayk[@]}
do
dk=`which $k`
dk1=$?
dks=$(sudo systemctl status $k 2>&1 > /dev/null)
dks1=$?
dks2=0
dksd=`ps -ef | grep $k | grep -v grep | awk '{split($0,a," "); print a[8]}' | grep $k | wc -l`
input="systemctl"
input1="runc"
input2="procn"
if [[ (( $dk1 -ne 0 )) ]]
then
	dk1="5"
fi
	#"$k"+=(["$input1"]="$dk1")
if [[ (( $dks1 -ne 0 )) ]]
then
	dks1="5"
fi


if [[ ( $k = "dockerd" ) ]]
then
dockerd+=([$input1]=$dk)
dockerd+=([$input]=$dks1)
dockerd+=([$input2]=$dksd)
elif [[ ( $k = "containerd" ) ]]
then
containerd+=([$input1]=$dk)
containerd+=([$input]=$dks1)
containerd+=([$input2]=$dksd)
else
	echo "no associative array"
fi

done

}


runcd1() {
for key in "${!dockerd[@]}"; do
    #rund=$(( $key + ${dockerd[$key]} ))

   if [[ ( $key = "runc" ) ]]
    then
	    if [[ ( ${dockerd[$key]} != "5")  ]]
	    then
		    echo "docker is installed in ${dockerd[$key]}"
      			Flag=1
	    fi
   fi
  
   if [[ ( $key = "systemctl" ) ]]
   then
            if [[ ( ${dockerd[$key]} != "5")  ]]
            then
                    echo "docker is default run-time activated by systemctl ${dockerd[$key]}"
		    DFlag=1
     		    drun=1
      		    Flag=1
            fi
   fi

   if [[ ($key = "procn") ]]
   then
	   if ( (( ${dockerd[$key]} >= 5 )) ) 
            then
                    echo "docker is the container run-time for the kubernetes cluster"
		    Flag=1
		    DFlag=1
                    drun=1
            fi
   fi

done

for key in "${!containerd[@]}"; do
    #rund=$(( $key + ${dockerd[$key]} ))

   if [[ ( $key = "runc" ) ]]
    then
            if [[ ( ${contaienrd[$key]} != "5")  ]]
            then
                    echo "Container is installed in ${containerd[$key]}"
                        Flag=1
	    fi
   fi

   if [[ ( $key = "systemctl" ) ]]
    then
            if [[ ( ${containerd[$key]} = "0")  ]]
            then
                    echo "Contaienrd is default run-time activated by systemctl"
		    Flag=1
      		    crun=1
            fi
   fi

   if [[ ( $key = "procn" ) ]]
    then
	    if ( (( ${containerd[$key]} >= 5 )) ) 
            then
                    echo "Containerd is the container run-time for the kubernetes cluster"
		    Flag=1
      		    crun=1
            fi
   fi
done

}



runc1=( dockerd containerd)
kuberun "${runc1[@]}"
runcd1


echo "the contaiern flag is $Flag and the Docker falg is $DFlag"
if [[ (( $crun -eq 0 )) && (( $drun -eq 0 )) ]]
then
echo "No Container compatible runtime"
fi

