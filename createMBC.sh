#!/bin/bash
NAME=`basename $0`
if [ $# -ne 6 -a  $# -ne 3 -a $# -ne 2 ]
then
	echo "Usage:	$NAME action(add) hostname profile mac interface ipaddress"
	echo "	$NAME action(edit) hostname newprofile "
	echo "	$NAME action(remove) hostname"
	echo "Example:$NAME add iaas-test RHEL6.6-x86_64 00:50:56:a6:1c:31 eth0 10.249.4.140"
	echo "	$NAME edit test1 RHEL6.0-x86_64"
	echo "	$NAME remove test1"
	exit 1
fi
#-------------定义函数---------
num2ip()
{
        local num=$1
        local a=$((num>>24))
        local b=$((num>>16&0xff))
        local c=$((num>>8&0xff))
        local d=$((num&0xff))

        echo "$a.$b.$c.$d"
}

ip2num()
{
        local ip=$1
        local IP_LIST=${ip//./ }
        read -a IP_ARRAY <<<${IP_LIST}
        echo $(( ${IP_ARRAY[0]}<<24|${IP_ARRAY[1]}<<16|${IP_ARRAY[2]}<<8|${IP_ARRAY[3]} ))
#       echo "$((($a<<24)+($b<<16)+($c<<8)+$d))"
}
#------------------------------

MBC_HISTORY=/home/sa/shell/`date +%s`.CSV
MBC_ACTION=$1
MBC_NAME=$2
HOST_NAME=$MBC_NAME
MBC_PROFILE=$3
MBC_MAC=`echo $4|sed 's/-/:/g'`
MBC_ETH=$5
#if [[ -n `echo $MBC_ETH|grep -i nic` ]];then
#	if [[ -n `echo $MBC_PROFILE|grep -i rhel6` ]];then
#		MBC_ETH=`echo em$(echo $MBC_ETH|awk -F- '{printf "%s\n", $2}')`
#	else
#		MBC_ETH=`echo eth$(echo $MBC_ETH|awk -F- '{printf "%s\n", $2-1}')`
#	fi
#else
#        MBC_ETH=$MBC_ETH
#fi
MBC_ETH=eth0
MBC_IP=$6
#--------配置NETMASK----------------
NETMASK='255.255.248.0'
for i in `seq 0 15`;do
    SUB="160.65.$i"
    if [[ `echo $MBC_IP|grep -w $SUB ` ]];then
        NETMASK='255.255.240.0'
    fi
done
#-----------------------------------

#--------配置GATEWAY----------------
BROADCAST=$(ipcalc -b $6 $NETMASK|awk -F= '{print $2}')
GATEWAY=$[ `ip2num $BROADCAST` - 1 ]
GATEWAY=$(num2ip GATEWAY)
#-----------------------------------

MAC_EXIST=`/usr/bin/cobbler system find --mac-address=$MBC_MAC`
if [[ $1 == "add" ]];then
	echo "/usr/bin/cobbler system  $MBC_ACTION --name=$MBC_NAME --hostname=$MBC_NAME --profile=$MBC_PROFILE --mac-address=$MBC_MAC --interface=$MBC_ETH --ip-address=$MBC_IP --netmask=$NETMASK --gateway=$GATEWAY" >> $MBC_HISTORY
	echo "/home/sa/shell/createMBC.sh $1 $2 $3 $4 $5 $6">>$MBC_HISTORY
	if [[ -n $MAC_EXIST ]];then
		 /usr/bin/cobbler system remove --name $MAC_EXIST	
	fi
	/usr/bin/cobbler system  $MBC_ACTION --name=$MBC_NAME --hostname=$MBC_NAME --profile=$MBC_PROFILE --mac-address=$MBC_MAC --interface=$MBC_ETH --ip-address=$MBC_IP --netmask=$NETMASK --gateway=$GATEWAY
elif [[ $1 = "edit" ]];then
	echo "/usr/bin/cobbler system edit --name=$MBC_NAME --hostname=$MBC_NAME --profile=$MBC_PROFILE" >> $MBC_HISTORY
	echo "/home/sa/shell/createMBC.sh $1 $2 $3 $4 $5 $6">>$MBC_HISTORY
	/usr/bin/cobbler system edit --name=$MBC_NAME --hostname=$MBC_NAME --profile=$MBC_PROFILE
elif [[ $1 = "remove" ]];then
	echo "/usr/bin/cobbler system  $MBC_ACTION --name=$MBC_NAME" >> $MBC_HISTORY
	 /usr/bin/cobbler system  $1 --name $2	
fi
#/usr/bin/cobbler sync >> /dev/null
exit 0
