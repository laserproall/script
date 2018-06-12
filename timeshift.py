#!/bin/python

import datetime,time

currentTime = datetime.datetime.now()  + datetime.timedelta(hours=-1)

wantTime=currentTime.strftime('%Y%m%d%H')

print wantTime
