#!/bin/bash
cat /dev/null > $HOME/.ssh/known_hosts
if [[ $# -ne 4 ]];then
  echo -e "\e[31mUsage:$(basename $0) HOST_ADDRESS USERNAME PASSWORD PORT\e[0m"
  exit
fi

CMD_ROOT=/ahmcc/Host/linux_scripts
#CMD_ROOT=/var/tmp
LOG=$CMD_ROOT/log/linux_scripts.$$.log
VALUE_LOG=$CMD_ROOT/log/value.$$.log
HOST_IP=$1
#USERNAME='aiuap'
#USERNAME=$2
#PASSWORD='aiuap123'
USERNAME=$2
PASSWORD=$3
SSH_PORT=$4
timestap=`date +%Y%m%d`
##########注释ssh端口检测##########
#IP_PORT=$(cat $CMD_ROOT/host_special_port.txt|grep -w $HOST_IP|sort|uniq)
#if [[ x$IP_PORT = x ]];then
#  SSH_PORT=22
# else
#  SSH_PORT=${IP_PORT##*,}
#fi
##################################

status=`/usr/local/python3/bin/python3 $CMD_ROOT/modified_password --host=$HOST_IP --port=$SSH_PORT --user=$USERNAME --pass=$PASSWORD`
#status=`python3 $CMD_ROOT/modified_password $HOST_IP $USERNAME $PASSWORD`
if [[ $status ]];then
  echo $status|tee -a $CMD_ROOT/log/error.log
  exit 1
fi




#--------------------CPU使用率----------------------------
/usr/bin/expect -c "
 set timeout 30
 spawn ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOST_IP} -p $SSH_PORT
 expect \"*password:\"
 send \"$PASSWORD\r\"
 expect \"*${USERNAME}*\"
 send \"sar -u 1 6\r\"
 expect \"*${USERNAME}*\"
 send \"echo\r\"
 expect \"*${USERNAME}*\"
 send \"top -d 1 -bn3\r\"
 expect \"*${USERNAME}*\"
 send \"echo\r\"
 expect \"*${USERNAME}*\"
 send \"free -m\r\"
 expect \"*${USERNAME}*\"
 send \"echo\r\"
 expect \"*${USERNAME}*\"
 send \"df -mPl\r\"
 expect \"*${USERNAME}*\"
 send \"echo\r\"
 expect \"*${USERNAME}*\"
 send \"sar -dp 1 3\r\"
 expect \"*${USERNAME}*\"
 send \"echo\r\"
 expect \"*${USERNAME}*\"
 send \"sar -n DEV 1 3\r\"
 expect \"*${USERNAME}*\"
 send \"exit\r\"
 expect eof
" > "${LOG}.cpu"
#--------------------CPU使用率----------------------------

CPUUsage=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "Average:" | grep all | awk 'BEGIN {FS="all"} {print $2}' | awk '{print $1+$2+$3+$4+$5}')
    if [[ -n $CPUUsage ]];then
     CPUUsage=`printf %.0f $(echo "$CPUUsage*100"|bc)`
    ECHOCPU=$(echo -e "{cpuusage:'${CPUUsage}',\c")
    #else
    #   CPUUsage='0'

    else
#CPUUsage=$(cat ${log}.cpu |grep -v "ssh\|password\|login\|@\|logout\|closed"|grep -i '^cpu'|awk '{print $2}'|sed 's/us,//'|sed 's/%//g')
        CPUUsage_TEMP=`cat ${LOG}.cpu | egrep -v "ssh\|password\|login\|@\|logout\|closed"| grep -i 'cpu'|grep 'id'|awk 'BEGIN {FS=","} {print $4}' | cut -d% -f1 | awk '{print $1}'`
        echo "$CPUUsage_TEMP" > $VALUE_LOG
        cpu=( $(cat $VALUE_LOG) )
        
        for (( i = 0; i < ${#cpu[@]}; ++i ))
          do
           cpu[$i]=${cpu[i]}
        done

#    echo "${cpu[0]}"
#    echo "${cpu[1]}"
#    echo "${cpu[2]}"

cpu1=0`echo "scale=2;100-${cpu[0]}" | bc`
#echo cpu1=$cpu1
cpu2=0`echo "scale=2;100-${cpu[1]}" | bc`
#echo cpu2=$cpu2
cpu3=0`echo "scale=2;100-${cpu[2]}" | bc`
#echo cpu3=$cpu3
       
 
        #rm -rf $VALUE_LOG
        sum=0`echo "scale=2;(${cpu1}+${cpu2}+${cpu3})/3" | bc`
#----------------比较CPU取出的数值是否大于100-----------------
        if [ $(echo "$sum > 100" | bc) = 1 ]
         then
                CPUUsage=100
        #       echo $CPUUsage
        # else
        #       echo "lt 100"
        fi
        CPUUsage=`printf %.0f $(echo "$sum*100"|bc)`
        
        if [[ -n $CPUUsage ]];then
         CPUUsage=`printf %.0f $(echo "$sum*100"|bc)`
        #else
        #   CPUUsage='0'
        fi
        ECHOCPU=$(echo -e "{cpuusage:'${CPUUsage}',\c")
        fi
#CPUUsage=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "Average:" | grep all | awk 'BEGIN {FS="all"} {print $2}' | awk '{print $1+$2+$3+$4+$5}')
#    if [[ -n $CPUUsage ]];then
#     CPUUsage=`printf %.0f $(echo "$CPUUsage*100"|bc)`
#    #else
#    #   CPUUsage='0'
#    fi
#    ECHOCPU=$(echo -e "{cpuusage:'${CPUUsage}',\c")


#rm -rf "${LOG}.cpu"
#echo $ECHOCPU

#--------------------内存使用率-----------------------------
#---------原脚本内容
#MEMUsage=`cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" |grep -i 'mem'|awk '{print $3}'`
#MEMTotal=`cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" |grep -i 'mem'|awk '{print $2}'`
#MEMPercent=`echo "scale=2;${MEMUsage} / ${MEMTotal} * 100"|bc`


#--------修改脚本内容
MEMFree=`cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "^Mem:" | grep -v total | awk '{print $4}'`
MEMTotal=`cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "^Mem:" | grep -v total | awk '{print $2}'`
MEMUsage=`echo "scale=2;${MEMTotal}-${MEMFree}"|bc`
MEMPercent=`echo "scale=2;${MEMUsage} / ${MEMTotal} * 100"|bc`

#ECHOMEM=$(echo -e "memusage:'${MEMUsage}MB',\c")
ECHOMEM=$(echo -e "memusage:'${MEMUsage}',\c")
#ECHOMEM1=$(echo -e "mempercent:'${MEMPercent}%',\c")
if [[ -n $MEMPercent ]];then
  MEMPercent=`printf %.0f $(echo "$MEMPercent*100"|bc)`
fi
  ECHOMEM1=$(echo -e "mempercent:'${MEMPercent}',\c")
#rm -rf "${LOG}.mem"



#--------------------内存使用率-----------------------------
#        /usr/bin/expect -c "
#                set timeout 30
#                spawn ssh -o StrictHostKeyChecking=no ${USERNAME}@$HOST_IP
#                expect \"*password:\"
#                send \"$PASSWORD\r\"
#                expect \"*${USERNAME}*\"
#                send \"free -m\r\"
#                expect \"*${USERNAME}*\"
#                send \"exit\r\"
#        	expect eof
#        " > "${LOG}.mem"
#        MEMUsage=`cat ${LOG}.mem | grep -v "ssh\|password\|login\|@\|logout\|closed" |grep -i 'mem'|awk '{print $3}'` 
#        MEMTotal=`cat ${LOG}.mem | grep -v "ssh\|password\|login\|@\|logout\|closed" |grep -i 'mem'|awk '{print $2}'`
#        MEMPercent=`echo "scale=2;${MEMUsage} / ${MEMTotal} * 100"|bc`
#        #ECHOMEM=$(echo -e "memusage:'${MEMUsage}MB',\c")
#        ECHOMEM=$(echo -e "memusage:'${MEMUsage}',\c")
#        #ECHOMEM1=$(echo -e "mempercent:'${MEMPercent}%',\c")
#        if [[ -n $MEMPercent ]];then
#        	MEMPercent=`printf %.0f $(echo "$MEMPercent*100"|bc)`
#        fi
#        ECHOMEM1=$(echo -e "mempercent:'${MEMPercent}',\c")
#        rm -rf "${LOG}.mem"
#        

#-----------------磁盘空间利用率统计---------------------------

ECHODISK=$(echo -e "diskusage:{\c")

#DiskSpace Usage
DISKSpaceUsage=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep -v 'Filesystem' | grep "^/dev/\|^dev" | awk '{printf "\047%s\047:\047%.2f\047\n",$1,$3/1024}'|grep dev|awk '{print}')
ECHODISK1=$(echo -e "$(echo $DISKSpaceUsage|sed 's/ /,/g')},\c")

#DiskSpace Percent
DISKSpacePercent=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep -v 'Filesystem'| grep "^/dev/\|^dev" | awk '{printf "\047%s\047:\047%.2f\047\n", $1,$5}'|grep dev|sed 's/ /,/g')
ECHODISK2=$(echo -e "diskpercent:{$(echo $DISKSpacePercent|sed 's/ /,/g')},\c")
rm -rf "${LOG}.disk"


#-------------------------------原脚本内容----------------------
#/usr/bin/expect -c "
#        set timeout 30
#        spawn ssh -o StrictHostKeyChecking=no ${USERNAME}@$HOST_IP
#        expect \"*password:\"
#        send \"$PASSWORD\r\"
#        
#        expect \"*${USERNAME}*\"
#        send \"df -mP\r\"
#        expect \"*${USERNAME}\"
#        send \"exit\r\"
#	expect eof
#" > ${LOG}.disk
#ECHODISK=$(echo -e "diskusage:{\c")
#
##DiskSpace Usage
#DISKSpaceUsage=$(cat ${LOG}.disk | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep -v 'Filesystem'|awk '{printf "\047%s\047:\047%.2f\047\n",$1,$3/1024}'|grep dev|awk '{print}')
#ECHODISK1=$(echo -e "$(echo $DISKSpaceUsage|sed 's/ /,/g')},\c")
#
##DiskSpace Percent
#DISKSpacePercent=$(cat ${LOG}.disk | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep -v 'Filesystem'|awk '{printf "\047%s\047:\047%.2f\047\n", $1,$5}'|grep dev|sed 's/ /,/g')
#ECHODISK2=$(echo -e "diskpercent:{$(echo $DISKSpacePercent|sed 's/ /,/g')},\c")
#rm -rf "${LOG}.disk"


#------------------磁盘读写速率----------------------------------

DISKRWKBps=$(cat ${LOG}.cpu | grep "^Average:" | grep "sd[a-z][^1-9]" | awk '{printf "\047%s\047:\047%.2f\047\n",$2,$4+$5}')
ECHODISK4=$(echo -e "diskrate:{$(echo $DISKRWKBps|sed 's/ /,/g')},\c")
DISKIOPS=$(cat ${LOG}.cpu | grep "^Average:" | grep "sd[a-z][^1-9]"|awk '{printf "\047%s\047:\047%.2f\047\n",$2,$3}')
ECHODISK5=$(echo -e "diskiops:{$(echo $DISKIOPS|sed 's/ /,/g')},\c")


#--------------------------------硬盘读写速率原脚本内容------------------------
#        /usr/bin/expect -c "
#                set timeout 30
#                spawn ssh -o StrictHostKeyChecking=no ${USERNAME}@$HOST_IP
#                expect \"*password:\"
#                send \"$PASSWORD\r\"
#                
#                expect \"*${USERNAME}*\"
#                send \"iostat -d -k 1 3\r\"
#                expect \"*${USERNAME}*\"
#                send \"exit\r\"
#        	expect eof
#        " > ${LOG}.diskwr
#        #Disk Read-Write KBps
#        DISKRWKBps=$(cat ${LOG}.diskwr | grep -v "ssh\|password\|login\|@\|logout\|closed"  | grep "sd[a-z][^1-9]"|awk '{printf "\047%s\047:\047%.2f\047\n",$1,$3+$4}')
#        ECHODISK4=$(echo -e "diskrate:{$(echo $DISKRWKBps|sed 's/ /,/g')},\c")
#        #Disk IOPS
#        DISKIOPS=$(cat ${LOG}.diskwr | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "sd[a-z][^1-9]"|awk '{printf "\047%s\047:\047%.2f\047\n",$1,$2}')
#        ECHODISK5=$(echo -e "diskiops:{$(echo $DISKIOPS|sed 's/ /,/g')},\c")
#        rm -rf ${LOG}.diskwr
#        
#--------------网卡速率Mbps---------------------------------

#/usr/bin/expect -c "
#        set timeout 30
#        spawn ssh -o StrictHostKeyChecking=no ${USERNAME}@$HOST_IP
#        expect \"*password:\"
#        send \"$PASSWORD\r\"
#        
#        expect \"*${USERNAME}*\"
#        send \"sar -n DEV 1 1\r\"
#        expect \"*${USERNAME}*\"
#        send \"exit\r\"
#	expect eof
#" > ${LOG}.net
#
#Network Mbps
NETMB=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | grep "Average:" | grep "eth[0-9]\|bond\|enp" | awk '{sub("[.]","_",$2);printf "%s:\047%.2f\047\n",$2,($5+$6)/1024}') 
#NETMB=$(cat ${LOG}.cpu | grep -v "ssh\|password\|login\|@\|logout\|closed" | egrep -vi 'IFACE|lo|linux|sit'|grep -i 'Average'|awk '{sub("[.]","_",$2);printf "%s:\047%.2f\047\n",$2,($5+$6)/1024}')
ECHONET=$(echo -e  "netmb:{$(echo $NETMB|sed 's/ /,/g')}}\c")
#rm -rf ${LOG}.net

#echo ${ECHOCPU}${ECHOMEM}${ECHOMEM1}${ECHODISK}${ECHODISK1}${ECHODISK2}${ECHODISK3}${ECHODISK4}${ECHODISK5}${ECHONET} > $LOG/linux_monitor_$timestap.log 
#MONITOR_LOG="/dev/null 2>&1"
#MONITOR_LOG="$CMD_ROOT/log/linux_monitor_`date '+%W'`.log"
#echo `date` >> $MONITOR_LOG
#echo -e "HOST=$HOST_IP \c" >> ${MONITOR_LOG}
#echo -e "$(date +%Y%m%d-%H%M%S)  \c" >> ${MONITOR_LOG}
echo ${ECHOCPU}${ECHOMEM}${ECHOMEM1}${ECHODISK}${ECHODISK1}${ECHODISK2}${ECHODISK3}${ECHODISK4}${ECHODISK5}${ECHONET}
#echo ${ECHOCPU}${ECHOMEM}${ECHOMEM1}${ECHODISK}${ECHODISK1}${ECHODISK2}${ECHODISK3}${ECHODISK4}${ECHODISK5}${ECHONET} | tee -a ${MONITOR_LOG}

rm -rf $VALUE_LOG
rm -rf ${LOG}.cpu
exit

