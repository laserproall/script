#!/bin/python

import datetime,time

currentTime = datetime.datetime.now()  + datetime.timedelta(days=-2)

wantTime=currentTime.strftime('%Y%m%d')

print wantTime
