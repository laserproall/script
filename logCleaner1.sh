#!/usr/bin/bash
# zhengyg2@asiainfo-linkage.com
# 2012.12.10

ismgHome=/opt/ismg55
#rawlog=/opt/ismg/rawlog

find $ismgHome -name BusiBak|while read line
do
    cd ${line}
    pwd
    find . -type f -size 0c -exec rm {} \;
    find . -type f -ctime +0 -exec rm {} \;
    [ $? -eq 0 ] && echo "`date +%Y-%m-%d" "%H:%M`  "deleted "$line" >> ${ismgHome}/logCleaner.log
done

find $ismgHome -name BillBak|grep -i logbak|while read line
do
    cd ${line}/ptop
    pwd
    find . -type f -size 0c -exec rm {} \;
    find . -type f -ctime +0 -exec rm {} \;
    [ $? -eq 0 ] && echo "`date +%Y-%m-%d" "%H:%M`  "deleted" $line">> ${ismgHome}/logCleaner.log
done

find $ismgHome -name BillTmp*|grep -i logbak|while read line
do
    cd ${line}
    pwd
    find . -type f -size 0c -exec rm {} \;
    find . -type f -ctime +0 -exec rm {} \;
    [ $? -eq 0 ] && echo "`date +%Y-%m-%d" "%H:%M`  "deleted" $line">> ${ismgHome}/logCleaner.log
done

find $ismgHome -name LogBak|while read line
do
    cd ${line}
    pwd
    find . -type f -size 0c |grep -vi bill|xargs rm
    find . -type f -ctime +0  |grep -vi bill|xargs rm
    [ $? -eq 0 ] && echo "`date +%Y-%m-%d" "%H:%M`  "deleted "$line" >> ${ismgHome}/logCleaner.log
done
