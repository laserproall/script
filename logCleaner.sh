#!/bin/bash
# liugq@asiainfo.com
# 2004.10.20

ismgHome=/opt/ismg50
rawlog=/opt/ismg50/rawlog
for line in `cat ${ismgHome}/ismgDir`
do
        if [ -s ${ismgHome}/${line}/bin/CHILD_0/LogBak ]
        then
                cd ${ismgHome}/${line}/bin/CHILD_0/LogBak
                echo `date +%Y-%m-%d" "%H:%M`  "delete $line logbak" >> ${ismgHome}/logCleaner.log
                find . -type f -size 0c -exec rm {} \;
                find . -type f -ctime +1  -exec rm {} \;
        fi
        if [ -s ${ismgHome}/${line}/bin/CHILD_0/BillBak ]
        then
                cd ${ismgHome}/${line}/bin/CHILD_0/BillBak
                for loop in `ls *\]`
                do
                        mv ${loop} ${rawlog}/${loop}.${line};
                done
        fi

        if [ -s ${ismgHome}/${line}/bin/CHILD_0/BillLogBack ]
        then
                cd ${ismgHome}/${line}/bin/CHILD_0/BillLogBack
                for loop in `ls *\]`
                do
                        mv ${loop} ${rawlog}/${loop}.${line};
                done
        fi

        if [ -s ${ismgHome}/${line}/bin/CHILD_0/BillTmpBak ]
        then
                cd ${ismgHome}/${line}/bin/CHILD_0/BillTmpBak
                for loop in `ls *\]`
                do
                        mv ${loop} ${rawlog}/${loop}.${line}.tmp
                done
        fi

        if [ -s ${ismgHome}/${line}/bin/CHILD_0/BillTempBak ]
        then
                cd ${ismgHome}/${line}/bin/CHILD_0/BillTempBak
                for loop in `ls *\]`
                do
                        mv ${loop} ${rawlog}/${loop}.${line}.tmp
                done
        fi
done
find ${rawlog} -type f -ctime +0 -exec rm {} \;
