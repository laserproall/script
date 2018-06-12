#!/usr/bin/bash
#### Write by smallfish
###  Date: 03/21/2005
###  This shell will bakup all ISMG module and ftp this bak files to a remote host
###  

echo "Shell Will Start"

cd $HOME
. .profile

version='ISMG2.0'

localhost=`hostname`
echo $localhost

bakdate=`date +%Y%m%d`
echo $bakdate

bakdir=$HOME/tmp/futsbak
if [ -d $bakdir ]
then
   echo "log bakdir exist"
else
   echo "log bakdir dont exist. make this bakdir"
   mkdir -p $bakdir
fi

fileflag=0
cat baklist.txt|while read line
do

        bakdate=`date +%Y%m%d%H%M%S`
        echo $bakdate
        dirname=`echo $line|awk '{print $1}'`
        appname=`echo $line|awk '{print $2}'`
        echo $appname
        if [ -s $bakdir/$localhost'_'$appname'_'$version'_'$bakdate'_bak.tar.gz' ]
        then
            mv $bakdir/$localhost'_'$appname'_'$version'_'$bakdate'_bak.tar.gz' $bakdir/$localhost'_'$appname'$fileflag_'$version'_'$bakdate'_bak.tar.gz'
            let fileflag=$fileflag+1
        fi
        tar cvf $bakdir/$localhost'_'$appname'_'$version'_'$bakdate'_bak.tar' $dirname/bin/$appname $dirname/config
        gzip $bakdir/*$appname'_'$version'_'$bakdate'_bak.tar'
        if [ $? -eq 0 ]
        then
           echo "$appname bak succeed!"
        else
           echo "$appname bak failed!"
        fi
done

### ftp bak files to a remote server
bakhost=10.3.80.135
user=ismg50
passwd=!ji6Rz9t
cd $bakdir
ftpdir=/ismg20/ismg50/ismgbak2.0
ftp -i -n $bakhost <<FTPBAK
	user $user $passwd
	cd $ftpdir
	mput *bak.tar.gz
	bye
FTPBAK

#rm all bak file
cd $bakdir
#rm *bak.tar.gz
echo $?

if [ $? -eq 0 ]
then
  echo "SUCCEED: Have deleted all baked files"
else
  echo "FAIL: Have not deleted all baked files"
fi

