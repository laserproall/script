#!/bin/bash
# E-mail: zhengyg2@asiainfo-linkage.com
# Date: 2012.3.31
# Networking AutoCheck Script
# set -x

source ~/.profile

echo "++++++++++++++++++++++++++++++++++++++++"
echo "       date:`date "+%Y/%m/%d %H:%M:%S"`"
echo "++++++++++++++++++++++++++++++++++++++++"

if [ ! -e networkinglist ] 
then
   echo "ERR: Need addition file:networkinglist" 
   exit 1
fi

##User/Passwd & checkcmd
loginforRTcisco="Gt#Gi3pc iUr5n#ph"
loginforRThuawei="Gt#Gi3pc"
loginforSWcisco="MT!HI9nv bi%uvr5A"
loginforSWhuawei="MT!HI9nv"
loginforFW="aTr7%fiu m!Dt9tjg"
loginforL4="pYg8m!Ij"
cmd1="sh ip int bri"
cmd2="dis ip int bri"
cmd3="dis int bri"
cmd4="sh int ip bri"
cmd5="show int"
cmd6="/info/link"
cmd7="show processes cpu"
cmd8="show processes memory"
cmd9="show cpu usage"
cmd10="show memory"
cmd11="dis cpu-usage"
cmd12="dis mem"
cmd13="dis memory-usage"
cmd14="/stats/mp/cpu"
cmd15="/stats/mp/mem"
cmd16="show logging"
cmd17="dis logbuf"
cmd18="show standby bri"
cmd19="dis vrrp"
cmd20="sh fa"




##Login shell
CISCO(){
cat <<EOF

**********************************
    
         IP:$4

**********************************

EOF

(sleep 1;echo admin; sleep 1; echo $1; sleep 1; echo en; sleep 1; echo $2;sleep 1;echo "$3" ;sleep 1; echo ' '; sleep 1;echo "$5";sleep 1;echo ' ';sleep 1 ;echo "$6";sleep 1;echo ' ';sleep 1;echo $7;sleep 1;echo '          ';sleep 1;echo $8;sleep 1;echo '        ';sleep 1)|telnet $4
}



HUAWEI(){
cat <<EOF

**********************************

         IP:$3

**********************************

EOF

(echo admin; sleep 1; echo $1; sleep 1; echo "$2" ;sleep 1; echo ' '; sleep 1;echo "$4";sleep 1;echo '  ';echo "$5";sleep 1;echo ' ';echo "$6";sleep 1;echo '           ';sleep 1;echo ' ';echo "$7";sleep 1;echo '                        ';sleep 1)|telnet $3
}




NORTEL(){
cat <<EOF

**********************************

         IP:$3

**********************************

EOF

(echo $1; sleep 1; echo "$2" ;sleep 1; echo ' '; sleep 1;echo "$4" ;sleep 1; echo ' '; sleep 1;echo "$5" ;sleep 1; echo ' '; sleep 1;)|telnet $3
}


for i in `sed -n '/RT-CISCO/,/RT-HUAWEI/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  CISCO-RT  ======"
      CISCO $loginforRTcisco "$cmd1" $i "$cmd7" "$cmd8"  "$cmd18" "$cmd16"
  fi
done

for i in `sed -n '/RT-HUAWEI/,/SW-CISCO/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  HUAWEI-RT  ======"
      HUAWEI $loginforRThuawei "$cmd2" $i "$cmd11" "$cmd12" "$cmd19" "$cmd17"
  fi
done

for i in `sed -n '/SW-CISCO/,/SW-HUAWEI/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  CISCO-SW  ======"
      CISCO $loginforSWcisco "$cmd1" $i "$cmd7" "$cmd8" "$cmd16"
  fi
done

for i in `sed -n '/SW-HUAWEI/,/FW-ASA/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  HUAWEI-SW  ======"
      HUAWEI $loginforSWhuawei "$cmd3" $i "$cmd11" "$cmd13" "$cmd17"
  fi
done

for i in `sed -n '/FW-ASA/,/FW-PIX/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  CISCO-ASA-FW  ======"
      CISCO $loginforFW "$cmd4" $i "$cmd9" "$cmd10" "$cmd20" "$cmd16"
  fi
done

for i in `sed -n '/FW-PIX/,/L4SW-Nortel/'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  CISCO-PIX-FW  ======"
      CISCO $loginforFW "$cmd5" $i "$cmd9" "$cmd10" "$cmd20" "$cmd16"
  fi
done

for i in `sed -n '/L4SW-Nortel/,$'p  networkinglist |sed '/^$/d'|grep -v '\[' | grep -v ^#|sed 's/#//g'`
do
  if [ ! -z $i ]
  then
      echo " "
      echo "=====  NORTEL-L4  ======"
#      NORTEL $loginforL4 "$cmd6" $i "$cmd14" "$cmd15"
  fi
done
