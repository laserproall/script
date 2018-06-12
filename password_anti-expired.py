#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import os,sys,pexpect,argparse,time,datetime

timeinfo=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
host_user_passwd = dict()
timestamp_days = 0
hostport = '22'


def data_filter(host_passwd_file):
    with open(host_passwd_file) as f:
        for i in f:
            user_passwd = dict()
            tmp = i.strip().split()
            if len(tmp)%2 != 1 or len(tmp) == 1:
                print('%s error!'% tmp[0])
                continue
            for x in range(1,len(tmp),2):
                user_passwd[tmp[x]] = tmp[x+1]
            host_user_passwd[tmp[0]] = user_passwd      

def handle(action):
    if action == 'change':
        for host in host_user_passwd:
            for curuser,password in host_user_passwd[host].items():
                child = pexpect.spawn('ssh -o StrictHostKeyChecking=no root@%s -p %s' %(host, hostport))
                #child.logfile = sys.stdout
                i = child.expect(["[Pp]assword", pexpect.EOF, pexpect.TIMEOUT])
                if i == 0:
                    child.sendline(host_user_passwd[host]['root'])
                elif i == 1:
                    print(host+","+timeinfo+","+child.before.strip("\r\n").decode('utf-8'))
                else:
                    print(host+","+timeinfo+",login failed!!!")
                    child.close(force=True)

                i = child.expect(['root@', "Permission denied", pexpect.EOF, pexpect.TIMEOUT])
                if i == 0:
                    child.sendline("passwd "+curuser)
                    child.expect(["New password",pexpect.EOF])
                    child.sendline(password)
                    child.expect(["Retype new password",pexpect.EOF])
                    child.sendline(password)
                    child.expect(["updated successfully",pexpect.EOF])
                    child.close(force=True)
                    print(host+' '+curuser+' updated successfully.')
                    #return child
                elif i == 1:
                    print(host+' '+child.after.decode('utf-8'))
                    child.close(force=True)
                else:
                    print(host+","+timeinfo+",close")
                    child.close(force=True)

    if action == 'day':
        for host in host_user_passwd:
            child = pexpect.spawn('ssh -o StrictHostKeyChecking=no root@%s -p %s' %(host, hostport))
            index = child.expect(["[Pp]assword", pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                child.sendline(host_user_passwd[host]['root'])
            elif index == 1:
                print(host+","+timeinfo+","+child.before.strip("\r\n"))
            else:
                print(host+","+timeinfo+",login failed!!!")
                child.close(force=True)

            index = child.expect(['root@', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                child.sendline('cat /etc/shadow | grep root')
                child.expect(['root@',pexpect.EOF])
                child.close(force=True)
                timestamp_days = child.before.decode('utf-8').split('\r\n')[1].split(':')[2]
                changed_day = datetime.datetime.strptime('19700101','%Y%m%d') + datetime.timedelta(days=int(timestamp_days))
                expired_day = changed_day + datetime.timedelta(days=90)
                print('-'*16+'\n'+host+':')
                print('Changed day is: %s\nExpired day is: %s' % (changed_day.strftime('%Y-%m-%d'),expired_day.strftime('%Y-%m-%d')))
            elif index == 1:
                print(host+","+timeinfo+","+child.after.decode('utf-8'))
                child.close(force=True)
            else:
                print(host+","+timeinfo+",close")
                child.close(force=True)


def main(args):
    data_filter(args.host_passwd_file)
#    print(host_user_passwd)
    handle(args.action)

#def parse_arguments(argv):
def parse_arguments():
    parser = argparse.ArgumentParser(description='haha passwd')
    
    parser.add_argument('action', type=str, 
        help='the action you want:day or change')
    parser.add_argument('host_passwd_file', type=str, 
        help='the relation of user/passwd to host')
    # parser.add_argument('version', type=str,
    #     help='the version of cmpp:like 20 30')

 #   return parser.parse_args(argv)
    return parser.parse_args()

if __name__ == '__main__':
    #main(parse_arguments(sys.argv[1:]))
    main(parse_arguments())