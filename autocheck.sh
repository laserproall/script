#!/bin/bash
# E-mail: zhengyg2@asiainfo-linkage.com
# Date: 2011.8.25
# AutoCheck Script
# set -x

if [ ! -e iplist ] 
then
   echo "ERR: Need addition file:iplist" >> check.log
   exit 1
fi

T=`date +"%Y%m%d-%T"`

cat > check.log << EOF

Checkdate: $T

EOF


# checkip
cat >> check.log << EOF

####### IP Link & netstat ########

EOF
sed -n  '/IPLIST/,/BILLING/'p  iplist |sed '/^$/d' | grep -v '\[' | grep -v '#' | while read line
do
   ping $line 2>/dev/null >> check.log
done

for i in 5016 5019 7890 7930 5000 #5016 5019 5542 7890 7895 7915 7930 7931 7920 5000     
do
if [ $i = 7890 -o $i = 7895 -o $i = 7915 ]
then
echo "" >> check.log
echo "********** netstat for sp:$i ************" >> check.log
echo "" >> check.log
netstat -an|grep $i|grep ESTABLISHED >> check.log
fi

if [ $i = 5016 -o $i = 5019 -o $i = 5542 ]
then
echo "" >> check.log
echo "********** netstat for SMC:$i ************" >> check.log
echo "" >> check.log
netstat -an|grep $i|grep ESTABLISHED >> check.log
fi

if [ $i = 7930 -o $i = 7931 -o $i = 7920 ]
then
echo "" >> check.log
echo "********** netstat for ISMG:$i ************" >> check.log
echo "" >> check.log
netstat -an|grep $i|grep ESTABLISHED >> check.log
fi

if [ $i = 5000 ]
then
echo "" >> check.log
echo "********** netstat for 016:$i ************" >> check.log
echo "" >> check.log
netstat -an|grep $i|grep ESTABLISHED >> check.log
fi
done


#checkapp
cat >> check.log << EOF

####### Applications Status #######

EOF
ps -ef|grep "\-m"|grep -v grep|sort >> check.log


# checkdisk
cat >> check.log << EOF

####### Hard Disk Usage #######

EOF
df -h >> check.log

 
# checkresource
cat >> check.log << EOF

####### CPU & Memory Usage #######

EOF
if [ `uname` = "SunOS" ]
then
   prstat -a 1 1 >> check.log
   vmstat 1 5 >> check.log
fi

if [ `uname` = "Linux" ]
then
   top -bn 1 >> check.log
   vmstat 1 5 >> check.log
fi


# checklog
cat >> check.log << EOF

####### check /var/adm/messages #######

EOF
echo "begin..." >> check.log
if ! tail -50 /var/adm/messages |grep -i err >> check.log
then
   echo "***No ERRs***" >> check.log
fi
echo "end" >> check.log


# checktablespace
if [ `netstat -an|grep '\.1521\>' | wc -l` -gt 0 ]
then 
cat >> check.log << EOF

####### TableSpace Usage #######

EOF
su - ismg50 -c "sqlplus -S ismg50/ismg500401" >> check.log <<EOF
set linesize 300 
set pagesize 9999
 
SELECT d.tablespace_name "table_name", NVL (u.bytes, 0) "size",
        NVL (u.bytes, 0) - NVL (f.bytes, 0) "used",
        NVL (f.bytes, 0) "availeble",
        TO_CHAR (100* (NVL (f.bytes, 0) / NVL (u.bytes, 0)),'999.99')|| '%' "free",
        d.status "status"
 FROM   dba_tablespaces d,
       (SELECT tablespace_name, SUM (bytes) bytes,
               SUM (maxbytes) maxbytes
        FROM   dba_data_files
        GROUP  BY tablespace_name) u,
       (SELECT tablespace_name, SUM (bytes) bytes
        FROM   dba_free_space
        GROUP  BY tablespace_name) f
        WHERE d.tablespace_name = u.tablespace_name(+)
        AND d.tablespace_name = f.tablespace_name(+)
        and d.LOGGING = 'LOGGING';
EOF
fi


# checkbill
for billdir in `sed -n '/BILLING/,$'p iplist | sed '/^$/d' | grep -v '\[' | grep -v '#'`
do
    if [ -d "$billdir" ]
    then
cat >> check.log << EOF

####### Check Billing #######
       
EOF
       echo "Billing Directory: $billdir" >> check.log
   
       if [ `ls $billdir | wc -l` -eq 0 ]
       then
          echo 'Billing is empty!' >> check.log
       else
          echo 'Billing is not empty, Now Listing...' >> check.log
          ls -lrt $billdir >> check.log
       fi
    fi
done


# checkvcs
if ifconfig -a|egrep '10.3.80.111|10.3.80.113|192.168.40.43' > /dev/null 2>&1
then 
cat >> check.log << EOF

####### Check VCS #######
   
EOF
#   echo "Please enter root password"
   su - root -c "hastatus -sum" >> check.log
fi

# ftp log files to a remote server

bakhost=10.3.80.117
user=ismg
passwd=Ae!7wpMay
cp check.log check.log@$HOSTNAME.$T
ftpdir=/opt/ismg/checklog
ftp -i -n $bakhost <<FTPBAK
        user $user $passwd
        cd $ftpdir
        mkdir `date +"%Y%m%d"`
        cd `date +"%Y%m%d"`
        put check.log@$HOSTNAME.$T 
        by
FTPBAK

# backuplog
[ -d logbak ] || mkdir logbak
mv check.log@$HOSTNAME.$T logbak/
