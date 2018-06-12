#!/bin/bash
#For BillMana3.0 billing transfer

source ~/.profile

if [ ! -e timeshift.py ]
then
echo "Err:timeshift.py not found."
exit 1
fi

DATE=`date +%Y%m%d%H`
DATE1=`python2.5 timeshift.py`

BillTmpbak=/ptpBill/ismg55/BillGather/BillTmpBak
BillManaDir=/ptpBill/ismg55/BillMana/BillTmpBak

find $BillTmpbak -type f -size 0c -exec rm {} \;
cd $BillTmpbak;

for i in `ls *.$DATE* *.$DATE1* |grep -v laber`
do

      if ! cp $i $BillManaDir
      then
          echo "Transfer $i failed!!!" >> WARNING.log
          #exit 1
      fi

      if ! mv $i $i.laber
      then
          echo "Laber $i failed!!!" >> WARNING.log
          #exit 1
      fi

done
