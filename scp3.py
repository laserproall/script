#!/usr/bin/env python3
# -*- coding:utf-8 -*-
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import sys
import os
import argparse

import queue
import xlrd
import xlwt
from xlutils.copy import copy




areacode_route = dict()
areacode_queue_route = dict()

tmpwb = xlrd.open_workbook('./areacodeInfo_tmp.xls',formatting_info = True, ragged_rows=True)
wb = copy(tmpwb)

ws = wb.get_sheet(0)
    
for i in range(6):
    ws.col(i).width = 256*25
    
    
    
def write2excel(row,phone,date):
    print(date)
    print(len(date))
    ws.write(row,0,phone)
    ws.write(row,1,phone)
    ws.write(row,2,date[3])
    ws.write(row,3,date[4])
    ws.write(row,4,date[2])
    ws.write(row,5,date[2])    

def save2excel(filename):
    wb.save(filename)



def set_route(routefile):
    with  open(routefile) as f:
        for line in f:
            if line.strip() == '': 
                print('this is a blank string')
                break
            route_list = line.strip().split(";")
            areacode_route[route_list[0]]=route_list[1]   
        print(areacode_route)



def data_filter(areacode_file):
    data = xlrd.open_workbook(areacode_file)
    table = data.sheets()[1]
    nrows = table.nrows
    print(nrows)
    for i in range(nrows):
        if i == 0:
           continue
        net_num = table.cell(i,2).value
        user = table.cell(i,3).value
        begin_phone = table.cell(i,0).value.ljust(11,'0')
        end_phone = table.cell(i,1).value.ljust(11,'9')
        #print(net_num)
        if net_num == "":
            break
        areacode = areacode_route[net_num]
        queue_name =  areacode + user + begin_phone[:3]
        #if not areacode_queue_route.has_key(queue_name):
        if not queue_name in areacode_queue_route:
            areacode_queue_route[queue_name] = list()
        l = areacode_queue_route[queue_name]
        l.append([begin_phone,end_phone,areacode,net_num,user])
    print(areacode_queue_route)

def data_format_info(b,e):
    for i in range(10,-1,-1):
        if not (b[i] == '0' and e[i] == '9'):
            break

    for k in range(i+1):
        if  b[k] != e[k]:
            break
            
    return b[:k],b[k:i+1],e[k:i+1]


def data_decrement(b,e):
    tmp_queue = list()
    begin_int = int(b)
    end_int = int(e)
    high = int(b[0])

    if len(b) == 1:
        for i in range(begin_int,end_int+1):     
            tmp_queue.append(str(i))
        return tmp_queue
    if b[0] == '0' and len(b) == 3:
        if e[0] == '0':
            q = data_decrement(b[1:],e[1:])
            for i in q:
                tmp_queue.append('0'+i) 
            return tmp_queue
        if e[0] != '0':
            if b[1] == '0' and b[2] == '0':
                tmp_queue.append('0')
                q = data_decrement('100',e)
                for i in q:
                    tmp_queue.append(i)
                return tmp_queue
            else:
                q = data_decrement(b[1:],'99')
                for i in q:
                    tmp_queue.append('0'+i)
                q = data_decrement('100',e)
                for i in q:
                    tmp_queue.append(i)
                return tmp_queue
            
         



    K = pow(10,len(b)-1)
    K1= pow(10,len(b)-1)
    print("b,e,high,K:%s %s %s %s" %(b,e,high,K))
    for j in range(1,11):
        
        A  = (high + j)*K
        B  = (high + j)*K -1
    

        if B < end_int:
            if len(b) == 2:
                if j == 1:
                    if b[0] == '0' and e[0] != '0' and b[1] == '0':
                        for i in range(0,int(e[0])):
                            tmp_queue.append(str(i))
                        if e[1] != '9':
                            for i in range(int(e[0]+'0'),int(e)+1):
                                tmp_queue.append(str(i))
                        else:
                            tmp_queue.append(e[0])
                        return tmp_queue
                    elif b[0] == '0' and e[0] != '0' and b[1] != '0':
                        for i in range(int(b[1]),10):
                            tmp_queue.append('0'+str(i))
                        for i in range(1,int(e[0])):
                            tmp_queue.append(str(i))
                        if e[1] != '9':
                            for i in range(int(e[0]+'0'),int(e)+1):
                                tmp_queue.append(str(i))
                        else:
                            tmp_queue.append(e[0])
                        return tmp_queue
                    elif  b[0] == '0' and e[0] == '0':
                        for i in range(0,int(e[1])+1):
                            tmp_queue.append('0'+str(i))
                        print("00,01")
                        print(tmp_queue)
                        return tmp_queue
                        
                    if b[1] == '0':
                        tmp_queue.append(str(high + j-1))
                        begin_int = A
                        continue        
                        
                    for i in range(begin_int,A):
                        tmp_queue.append(str(i))
                    begin_int = A
                    continue
                else:
                    tmp_queue.append(str(high + j-1))

                    begin_int = A
                    continue
            if j != 1 or (b.count('0') == len(b)-1):
                tmp_queue.append(str(high + j-1))
                begin_int = A
                continue
            next_begin = str(begin_int)[1:]
            next_end   = str((A - 1))[1:]
            print("debug next:%s %s" % (next_begin,next_end))
            print("debug next int::%s %s" % (begin_int,end_int))            
            q = data_decrement(next_begin,next_end)
            print("begin,end%s %s" %(b,e))
            print(q)
            for i in q:
                tmp_queue.append(str(begin_int)[0]+i)                
            begin_int = A
            continue
        elif B == end_int:
            if begin_int%10 == 0:
                tmp_queue.append(str(high + j-1))
                print(str(high + j-1))
                print(A)
                begin_int = A
                continue
            else:
                for i in range(begin_int,A):
                        tmp_queue.append(str(i))
                        print(str(i))
                begin_int = A
                continue                
                
        else:
            if begin_int > end_int:
                print("end")
                return tmp_queue
            elif begin_int == end_int:
                tmp_queue.append(e)
                return tmp_queue
            if len(b) == 2:
                if b[0] == '0' and e[0] != '0' and b[1] == '0':
                    for i in range(0,int(e[0])):
                        tmp_queue.append(str(i))
                    if e[1] != '9':
                        for i in range(int(e[0]+'0'),int(e)+1):
                            tmp_queue.append(str(i))
                    else:
                        tmp_queue.append(e[0])
                    return tmp_queue
                elif b[0] == '0' and e[0] != '0' and b[1] != '0':
                    for i in range(int(b[1]),10):
                        tmp_queue.append('0'+str(i))
                    for i in range(1,int(e[0])):
                        tmp_queue.append(str(i))
                    if e[1] != '9':
                        for i in range(int(e[0]+'0'),int(e)+1):
                            tmp_queue.append(str(i))
                    else:
                        tmp_queue.append(e[0])
                    return tmp_queue
                elif  b[0] == '0' and e[0] == '0':
                    for i in range(0,int(e[1])+1):
                        tmp_queue.append('0'+str(i))
                    return tmp_queue
                for i in range(begin_int,end_int+1):
                    tmp_queue.append(str(i))
                return tmp_queue
            else:
                next_begin = str(begin_int)[1:]
                next_end   = str(end_int)[1:]
                print("debug next:%s %s" % (next_begin,next_end))
                print("debug next int::%s %s" % (begin_int,end_int))
                q = data_decrement(next_begin,next_end)
                print("begin,end%s %s" %(b,e))
                print(q)
                for i in q:
                    tmp_queue.append(str(begin_int)[0]+i) 
                begin_int = A

def data_format_output(data_list):
    
    for line in data_list:
        base,b,e = data_format_info(line[0],line[1])
        if len(b) == 1:
            output = "86|0|"+base + b+"|"+line[2]
            print(output)
            output_file.write(output)
        else:
            begin_int = int(b)
            end_int = int(e)
            high = int(b[0])
            K = pow(10,len(b))
            A  = (high + 1)*K
            B  = (high + 2)*K -1

            if B < end_int:
                output = "86|0|"+base + high+"|"+line[2]
                print(output)
                output_file.write(output)
            else:
                pass

        #for i in range(begin_int,end_int):


def handle_scp(version):
    row = 1
    for n,l in areacode_queue_route.items():
        #print("begin to handle :%s" % n.encode('gbk'))
        print("begin to handle :%s" % n)
        l.sort(key = lambda x:x[0])
        filename = "SCP"+"_"+version+".txt"
        with open(filename,'a') as f:
            if len(l) == 1:
                print("####queue data####")
                print(l)
                prefix,begin_diff,end_diff = data_format_info(l[0][0],l[0][1])
                q = data_decrement(begin_diff,end_diff)
                for i in q:
                    print(prefix+i)
                    f.write("86|0|"+prefix+i+"|"+l[0][2]+"\n")
                    write2excel(row,str(prefix+i),l[0])
                    row += 1
            else:
            #data = "86|0|"+
                tmp_list = list()    
                next_num = 1
                a=""
                for d in range(len(l)):
                    if next_num == 1:
                        a = l[d]
                    b = l[d+1]
                    A0 = int(a[0])
                    A1 = int(a[1])
                    B0 = int(b[0])
                    B1 = int(b[1])
                    if A0 <= B0:
                        if B0 <= (A1+1):
                            a[1] =  (a[1] if A1 > B1 else b[1])
                            next_num = 0
                            if d == (len(l)-2):
                                tmp_list.append(a)
                                break    
                        else:
                            tmp_list.append(a)
                            next_num = 1
                            if d == (len(l)-2):
                                tmp_list.append(b)      
                                break
                    else:
                         print("error A0 > B0")
                print(tmp_list)
                for d in tmp_list:
                    prefix,begin_diff,end_diff = data_format_info(d[0],d[1])
                    print(prefix+"  "+begin_diff+"  "+end_diff)
                    q = data_decrement(begin_diff,end_diff)
                    for i in q:
                        print(prefix+i)
                        f.write("86|0|"+prefix+i+"|"+d[2]+"\n")
                        write2excel(row,str(prefix+i),d)
                        row += 1
        

    
    
    

def main(args):
#    q = data_decrement("101","388")
#    for i in q:
#        print(i)
    set_route(args.areacode_route)
    data_filter(args.areacode_file)
    handle_scp(args.version)
    filename = './'+args.version+'_areacodeInfo_new.xls'
    save2excel(filename)

#def parse_arguments(argv):
def parse_arguments():
    parser = argparse.ArgumentParser(description='haloe')
    
    parser.add_argument('areacode_file', type=str, 
        help='the excel of areacodeInfo file')
    parser.add_argument('areacode_route', type=str, 
        help='the relation of gateway number to areacode')
    parser.add_argument('version', type=str,
        help='the version of cmpp:like 20 30')


 #   return parser.parse_args(argv)
    return parser.parse_args()

if __name__ == '__main__':
    #main(parse_arguments(sys.argv[1:]))
    main(parse_arguments())
