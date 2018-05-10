
#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import sys,os,re,time,socket,getopt
import pexpect
timeinfo=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

def Usage():
    print("""Help information:
    --host: a IP or domain name
    --port: server port
    --user: ssh login username
    --passwd: password
    --help: print help info
    Example: 
    ./modified_password.py --host=1.1.1.1 --port=22 --user=imonitor --pass='1q2w#E$R'
    """)

def check_ip_ping(host,port):
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM) # ´´½¨Ì×½Ó×Ö
    s.settimeout(1) # ÉèÖÃ³¬Ê±Ê±¼ä
    result = s.connect_ex((host,port))
    if result == 0:
        return True
    else:
        return False

def ssh_login(curuser,host,hostport,curpass,tmppass):
    child = pexpect.spawnu('ssh -o StrictHostKeyChecking=no %s@%s -p %s' %(curuser, host, hostport))
    #child.logfile = sys.stdout
    i = child.expect(["[Pp]assword", pexpect.EOF, pexpect.TIMEOUT])
    if i == 0:
        child.sendline(curpass)
    elif i == 1:
        print(host+","+timeinfo+","+child.before.strip("\r\n"))
    else:
        print(host+","+timeinfo+",script match filed!!! ")
        child.close(force=True)
        
    i = child.expect(["(.*?) UNIX password:",curuser+"@", "Permission denied", pexpect.EOF, pexpect.TIMEOUT])
    if i == 0:
        child.sendline(curpass)
        child.expect("New password:")
        child.sendline(tmppass)
        child.expect("Retype new password")
        child.sendline(tmppass)
        child.expect("updated successfully")
        return "newpass"
    elif i == 1:
        child.close(force=True)
        #return child
    elif i == 3:
        print(host+","+timeinfo+","+child.after)
        child.close(force=True)
    else:
       child.close(force=True)

def new_ssh_login(curuser,host,hostport,curpass,tmppass):
    child = pexpect.spawnu('ssh -o StrictHostKeyChecking=no %s@%s -p %s' %(curuser, host, hostport))
    #child.logfile = sys.stdout
    i = child.expect(["[Pp]assword", pexpect.EOF, pexpect.TIMEOUT])
    if i == 0:
        child.sendline(tmppass)
    elif i == 1:
            print(host+","+timeinfo+","+child.before.strip("\r\n"))
    else:
        print(host+","+timeinfo+",login failed!!!")
        child.close(force=True)

    i = child.expect([curuser+"@", "Permission denied", pexpect.EOF, pexpect.TIMEOUT])
    if i == 0:
        child.sendline("sudo passwd "+curuser)
        child.expect("sudo.*?password for")
        child.sendline(tmppass)
        child.expect(["New password",pexpect.EOF])
        child.sendline(curpass)
        child.expect(["Retype new password",pexpect.EOF])
        child.sendline(curpass)
        child.expect(["updated successfully",pexpect.EOF])
        child.close(force=True)
        #return child
    elif i == 1:
        print(host+","+timeinfo+","+child.after)
        child.close(force=True)
    else:
       print(host+","+timeinfo+",close")
       child.close(force=True)

def main():
    if len(sys.argv) < 4:
        Usage()
        sys.exit(1)
    try:
        opts, args = getopt.getopt(sys.argv[1:],'',["host=","port=","user=","pass="])
        for k,v in opts:
            if k == '--host':
                host = v
            elif k == '--port':
                hostport = int(v)
                if not hostport:
                    hostport = 22
            elif k == '--user':
                curuser = v
            elif k == '--pass':
                curpass = v
    except getopt.GetoptError as err:
        Usage()
        print(str(err))
        sys.exit(1)
    tmppass='2wsx#EDC2wsx#EDC'
    if check_ip_ping(host,hostport):
        ssh = ssh_login(curuser,host,hostport,curpass,tmppass)
        if ssh == "newpass":
            ssh = new_ssh_login(curuser,host,hostport,curpass,tmppass)
    else:
        print("%s,%s,network unreachable or %s port is not open"%(host,timeinfo,hostport))

main()









