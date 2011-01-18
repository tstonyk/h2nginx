#!/usr/bin/env python
import yaml
import os
from xml.dom import minidom
import sys
sys.path.append('/scripts/')
import xmlapi


def writeconfded(user, domain, docroot, passedip, alias, aliasstring):
	user = user
	domain = domain
	passedip = passedip
	dedipvhost = """server {
          error_log /var/log/nginx/vhost-error_log warn;
          listen 80;
          server_name %s %s %s;
          access_log /usr/local/apache/domlogs/%s bytes_log;
          access_log /usr/local/apache/domlogs/%s combined;
          location ~* \.(gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|htm|html|txt|js|css|exe|zip|rar|gz|tgz|uha|7z|doc|docx|xls|xlsx|pdf)$ {
          root %s;
          }
          location / {
            client_max_body_size    10m;
            client_body_buffer_size 128k;
            proxy_send_timeout   90;
            proxy_read_timeout   90;
            proxy_buffer_size    4k;
            proxy_buffers     16 32k;
            proxy_busy_buffers_size 64k;
            proxy_temp_file_write_size 64k;
            proxy_connect_timeout 30s;
            proxy_redirect http://%s:8081 http://%s;
            %s
            proxy_redirect http://%s:8081 http://%s;
	    proxy_pass http://%s:8081/;    
            proxy_set_header   Host   $host;
            proxy_set_header   X-Real-IP  $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          }
        }""" % (domain, alias, passedip, domain + "-bytes_log", domain, docroot, domain, domain, aliasstring, passedip, passedip, passedip)
	if not os.path.exists( '/etc/nginx/conf.d'):
		os.makedirs('/etc/nginx/conf.d')
        if os.path.exists( '/etc/nginx/staticvhosts/' + domain+".conf"):
                pass
        else:
			domainvhost = open ('/etc/nginx/conf.d/' + domain +".conf", 'w')
			domainvhost.writelines( dedipvhost )
			domainvhost.close()

def writeconfshared(user,domain,docroot,passedip, alias,aliasstring):
        sharedipvhost = """server {
          error_log /var/log/nginx/vhost-error_log warn;
          listen 80;
          server_name %s %s;
          access_log /usr/local/apache/domlogs/%s bytes_log;
          access_log /usr/local/apache/domlogs/%s combined;
          location ~* \.(gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|htm|html|txt|js|css|exe|zip|rar|gz|tgz|uha|7z|doc|docx|xls|xlsx|pdf)$ {
          root %s;
          }
          location / {
            client_max_body_size    10m;
            client_body_buffer_size 128k;
            proxy_send_timeout   90;
            proxy_read_timeout   90;
            proxy_buffer_size    4k;
            proxy_buffers     16 32k;
            proxy_busy_buffers_size 64k;
            proxy_temp_file_write_size 64k;
            proxy_connect_timeout 30s;
            proxy_redirect http://%s:8081 http://%s;
            %s
	    proxy_pass http://%s:8081/;    
            proxy_set_header   Host   $host;
            proxy_set_header   X-Real-IP  $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          }
        }""" % (domain, alias, domain + "-bytes_log", domain, docroot, domain, domain, aliasstring, passedip)
	if not os.path.exists( '/etc/nginx/conf.d'):
		os.makedirs('/etc/nginx/conf.d')
	if os.path.exists( '/etc/nginx/staticvhosts/' + domain +".conf"):
		pass
	else:
		domainvhost = open ('/etc/nginx/conf.d/' + domain +".conf", 'w')
     	domainvhost.writelines( sharedipvhost )
		domainvhost.close()

#def redirectfunc():



def getmainip():
	ipDOC = xmlapi.api("listips")
	parsedipDOC = minidom.parseString(ipDOC)
	iptaglist = parsedipDOC.getElementsByTagName('ip')
	serverip = iptaglist[0].childNodes[0].toxml()
	return serverip

def getipliststring():
        ipDOC = xmlapi.api("listips")
        parsedipDOC = minidom.parseString(ipDOC)
        iptaglist = parsedipDOC.getElementsByTagName('ip')
        iplist =[]

        q = 0
        while q < len(iptaglist):
                iplist.append(str(iptaglist[q].childNodes[0].toxml()))
                q = q + 1
        ipliststring = ' '.join(iplist)

        return ipliststring



def getvars(ydomain):
	DOC = xmlapi.api("domainuserdata?domain=" + ydomain)
	parsedDOC = minidom.parseString(DOC)
	droottaglist = parsedDOC.getElementsByTagName('documentroot')
	yiptaglist = parsedDOC.getElementsByTagName('ip')
	aliastaglist=[]
	aliastaglist = parsedDOC.getElementsByTagName('serveralias')
	droot=""
	alias=""
	yip=""
	try:
		alias = aliastaglist[0].childNodes[0].toxml()
		droot = droottaglist[0].childNodes[0].toxml()
		yip = yiptaglist[0].childNodes[0].toxml()

	except IndexError:
		errf=open('/root/failedcreation.txt', 'a')
		import time
		from time import strftime
		t=strftime("%Y-%m-%d %H:%M:%S")
		errortxt="%s Failed to create vhost for %s" % (t, ydomain)	
		errf.write(errortxt)
		errf.close()

	return droot, yip, alias

if __name__ == '__main__':
	DOC = xmlapi.api("listaccts")
	parsedDOC = minidom.parseString(DOC)
	usertaglist = parsedDOC.getElementsByTagName('user')
	userlist = []
	numusers = 0
	while numusers < len(usertaglist):
		userlist.append(str(usertaglist[numusers].childNodes[0].toxml()))
		numusers = numusers + 1
	for i in userlist:
		f = open('/var/cpanel/userdata/' + i + '/main')
		ydata = yaml.load(f)
		f.close()
		sublist = ydata['sub_domains']
		addondict = ydata['addon_domains']
		parkedlist = ydata['parked_domains']
		mainlist = ydata['main_domain']
		serverip = getmainip()
		if len(sublist) != 0:
			slcont = 0
			while slcont < len(sublist):
				domain = sublist[slcont]
				docroot, yip, alias = getvars(sublist[slcont])
				if docroot == "":
					slcont = slcont + 1
				else:
					aliaslist = alias.split()
					aliasstring = ""
					for zebra in aliaslist:
						aliasstring = "proxy_redirect http://%s:8081 http://%s;" % (zebra,zebra) + '\n\t\t' + aliasstring
					if yip == serverip:
						writeconfshared(i, domain, docroot, yip, alias, aliasstring)
					else:
						writeconfded(i, domain, docroot, yip, alias, aliasstring)
					slcont = slcont + 1
	
	
		DOC = xmlapi.api("accountsummary?user=" + i)
		parsedDOC = minidom.parseString(DOC)
		domaintaglist = parsedDOC.getElementsByTagName('domain')
		domain = domaintaglist[0].childNodes[0].toxml()
		docroot, yip, alias = getvars(domain)
		aliaslist = alias.split()
		aliasstring = ""
		for zebra in aliaslist:
			aliasstring = "proxy_redirect http://%s:8081 http://%s;" % (zebra,zebra) + '\n\t\t' + aliasstring
		if yip == serverip:
		       writeconfshared(i, domain, docroot, yip, alias, aliasstring)
		else:
		       writeconfded(i, domain, docroot, yip, alias, aliasstring)

