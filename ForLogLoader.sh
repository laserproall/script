#!/bin/bash
set -x
source ~/.profile

TIMESTAMP=$(python ForLogLoader.py)
CLEARDIR=/cu_disk/ismg55/LogLoader/Data

cd $CLEARDIR
mv *$TIMESTAMP* ../Datatmp
