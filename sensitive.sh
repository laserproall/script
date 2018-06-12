#!/bin/sh

#***********************�� ��***********************
#ҵ��ϵͳ����
SYSTEM="ShortMessageSystem" 
#ҵ��ϵͳ���
SYSTEM_NO="101"
#�ļ�����¼����Ĭ��10000
FILE_MAX_RECORD="10000"
#��¼ת��UTF-8����: �����ݿ����ΪGB��������Ϊ1�������ݿ����ΪUTF-8��������Ϊ0
EnableGB2UTF8="0"

#FTP��������IP��ַ
FTP_SERVER=10.3.3.111
#FTP��������¼���û���
FTP_USER=chenhb
#FTP��������¼���û�����
FTP_PASSWORD=chenhb
#FTP����������������־��Ŀ¼
FTP_ROOT_DIR=/jtsjsb

#���ݿ��û���
DB_USER="ismg55_test"
#���ݿ��û�����
DB_PASSWORD="ismg55_test"
#���ݿ�TNS
DB_TNSNAME="oracle107"
#*****************************************************

#��ȡ��ǰʱ��ǰN�������ʱ��
getLastDate() {
    LastDate=`perl -e "print sprintf '%04d%02d%02d%02d%02d%02d',
        (localtime(time()-$1))[5]+1900,
        (localtime(time()-$1))[4]+1,
        (localtime(time()-$1))[3],
        (localtime(time()-$1))[2],
        (localtime(time()-$1))[1],
        (localtime(time()-$1))[0]"`
    echo $LastDate
}

#��ȡ��ǰʱ��ǰ1���������
LastDate=`getLastDate 24*60*60 | cut -c 1-8`
DateYear=`echo $LastDate | cut -c 1-4`
DateMonth=`echo $LastDate | cut -c 5-6`
DateLastDay=`echo $LastDate | cut -c 7-8`

#����������־���ϴ�Ŀ¼
FTP_TARGET_DIR=$FTP_ROOT_DIR"/"$SYSTEM_NO"/"$DateYear"/"$DateMonth"/"$DateLastDay

if [ ! -f ".sensitive.maxseq" ];then
    echo 0 > ".sensitive.maxseq"
fi

#����������־�ѻ�ȡ��¼��������кţ���ֹ�ظ���ȡ
max_seqno=`cat ".sensitive.maxseq"`

SQL="select op_id, '|', main_account, '|', secondary_account, '|', secondary_account_type, '|', 
    sys_num, '|', access_mode, '|', server_ip, '|', client_ip, '|', op_time, '|', op_num, '|', 
    op_content, '|', sensitive_name, '|', sensitive_range, '|', sensitive_type, '|', op_flag, '|', 
    op_flag_type, '|', op_flag_id, '|', seqno, '\n' 
    from ismg_sensitive_data_log where seqno >= $max_seqno and op_time like '$LastDate%' order by op_time"

#echo $SQL

PLATFORM=`uname -s`

#1. create dir
DataDir="`pwd`/Data"
DataBak="`pwd`/DataBak"
DataErrBak="`pwd`/DataErrBak"
DataLog="`pwd`/sensitive.log"

if [ ! -d "$DataDir" ];then
  mkdir $DataDir
fi

if [ ! -d "$DataBak" ];then
    mkdir $DataBak
fi

if [ ! -d "$DataErrBak" ];then
    mkdir $DataErrBak
fi

#2. connect to database and select 
RECORD=`sqlplus -S $DB_USER/$DB_PASSWORD@$DB_TNSNAME << EOF
set heading off
set feedback off
set pagesize 0
set verify off
set echo off
$SQL;
exit
EOF`

if [ $PLATFORM = "SunOS" ];then
  echo_cmd="echo"
  awk_cmd="nawk"
else
  echo_cmd="echo -e"
  awk_cmd="awk"
fi

#3. format data to txt file
$echo_cmd $RECORD | $awk_cmd -F'|' -v sys="$SYSTEM" -v max_record="$FILE_MAX_RECORD" -v data_dir="$DataDir" '
BEGIN {
  count = 0
  seq = 1 
  date = ""
  last_file = "" 
  file = ""
  seqincred = 0;
  max_seqno = 0;
}

{
  #total 18 fields
  if(NF != 18) {
    next;
  }
  
  op_id                   = $1;   gsub(/^ +| +$/, "", op_id);
  main_account            = $2;   gsub(/^ +| +$/, "", main_account);
  secondary_account       = $3;   gsub(/^ +| +$/, "", secondary_account);
  secondary_account_type  = $4;   gsub(/^ +| +$/, "", secondary_account_type);
  sys_num                 = $5;   gsub(/^ +| +$/, "", sys_num);
  access_mode             = $6;   gsub(/^ +| +$/, "", access_mode);
  server_ip               = $7;   gsub(/^ +| +$/, "", server_ip);
  client_ip               = $8;   gsub(/^ +| +$/, "", client_ip);
  op_time                 = $9;   gsub(/^ +| +$/, "", op_time);
  op_num                  = $10;  gsub(/^ +| +$/, "", op_num);
  op_content              = $11;  gsub(/^ +| +$/, "", op_content);
  sensitive_name          = $12;  gsub(/^ +| +$/, "", sensitive_name);
  sensitive_range         = $13;  gsub(/^ +| +$/, "", sensitive_range);
  sensitive_type          = $14;  gsub(/^ +| +$/, "", sensitive_type);
  op_flag                 = $15;  gsub(/^ +| +$/, "", op_flag);
  op_flag_type            = $16;  gsub(/^ +| +$/, "", op_flag_type);
  op_flag_id              = $17;  gsub(/^ +| +$/, "", op_flag_id);
  op_seqno                = $18;  gsub(/^ +| +$/, "", op_seqno);

  if(max_seqno - op_seqno < 0) {
    max_seqno = op_seqno
  }

  data = sprintf("%s_%06d|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\r\n", 
    op_id, count, main_account, secondary_account, secondary_account_type, sys_num, access_mode,
    server_ip, client_ip, op_time, op_num, op_content, sensitive_name, sensitive_range, sensitive_type,
    op_flag, op_flag_type, op_flag_id);

  if(count > 0 && date != substr(op_time,1,10)) {
    seq = 1;
  }

  date = substr(op_time,1,10);

  if(array[file] > 0 && array[file] % max_record == 0) {
    seq++;    
  }

  file = sprintf("%s/%s%s%02d.txt", data_dir, sys, substr(op_time,1,10), seq);

  if(last_file != "" && last_file != file) {
    close(last_file)
  }

  printf data > file;

  last_file = file;

  array[file]++;
  
  count++;
}

END {
  if(max_seqno != 0) {
    print max_seqno+1 > ".sensitive.maxseq"
  }
}' 2>/dev/null

#4. ftp txt file to 4A system
if [ "$PLATFORM" = "SunOS" ];then
     TIMEOUT="-T 3"
else
     TIMEOUT=""
fi

cd $DataDir

for file in `ls $DataDir | grep -v '^d'`
do
  #******gb to utf8******
  if [ $EnableGB2UTF8 = "1" ];then
    iconv -f gb2312 -t UTF-8 -c "$file" > tmp 
      mv -f tmp "$file" 
  fi

  #******ftp*************
  FTP_CMD=`ftp -n -v $TIMEOUT << EOF 2>&1
    open $FTP_SERVER
    user $FTP_USER $FTP_PASSWORD
    ascii
    mkdir $FTP_ROOT_DIR/$SYSTEM_NO/$DateYear
    mkdir $FTP_ROOT_DIR/$SYSTEM_NO/$DateYear/$DateMonth
    mkdir $FTP_ROOT_DIR/$SYSTEM_NO/$DateYear/$DateMonth/$DateLastDay 
    put $file $FTP_TARGET_DIR/$file 
    bye
    EOF`

  RESP=`echo "$FTP_CMD"`
  RESULT=`echo "$RESP" | grep -i "226 Transfer complete"`

  if [ "$RESULT" !=  "" ];then
    mv $file $DataBak
    $echo_cmd "`date \"+%Y-%m-%d %H:%M:%S\"`# INFO: ftp $file to $FTP_SERVER($FTP_TARGET_DIR) ok! \n`echo "$RESP"`\n" >> $DataLog
  else
    mv $file $DataErrBak
    $echo_cmd "`date \"+%Y-%m-%d %H:%M:%S\"`# ERROR: ftp $file to $FTP_SERVER($FTP_TARGET_DIR) fail! \n`echo "$RESP"`\n" >> $DataLog
  fi
done

