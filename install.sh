#!/bin/bash
# h2nginx install Bash script
#
# Only compatible with cPanel installations on RPM based distributions
#-----------------------------------------------------------------------

#
#	Check for RPM based and cPanel install
#

if [ ! -f "/etc/redhat-release" ]; then
	echo "This is not a RPM based distribution"
	exit 0;
fi

if [ ! -f "/usr/local/cpanel/cpanel_version" ]; then
	echo "cPanel is not installed on this server";
	exit 0;
fi

#### Private functions
function _addRepo {

if [ ! -f "/etc/yum.repos.d/centalt.repo" ]; then 
	echo "	[CentALT] 
			name=CentALT Packages for Enterprise Linux 5 - $basearch 
			baseurl=http://centos.alt.ru/repository/centos/5/$basearch/
			enabled=0 
			gpgcheck=0" >> /etc/yum.repos.d/centalt.repo
fi
}

function _removeRepo {
	if [ -f "/etc/yum.repos.d/centalt.repo" ]; then 
			rm -f /etc/yum.repos.d/centalt.repo
	fi
}

#
#	Proceed with the installation
#

if [ "$1" == "install" ]; then 
	cd /usr/src
	
	echo " h2nginx installer :::::: "
	
	_addRepo
	echo "... Let's install nginx firest ...."
	yum -y install --enablerepo=CentALT nginx 
	
	echo ""
	echo " Preparing the installation"
	echo " "
	echo "... Downloading mod rpaf from stderr.net ..." 
	wget http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz > /dev/null 2>&1	
	
	echo "... Extract mod_rpaf ..."
	tar xzfv mod_rpaf-0.6.tar.gz > /dev/null 2>&1	
	
	echo "... Install PyYAML ..."
	easy_install PyYAML  
	
	echo "... Proceed with the installation ..."
	/usr/bin/python ./nginxinstaller install
	
elif [ "$1" == "uninstall" ]; then
	echo "... Remove nginx repository ..."
	_removeRepo
	
	echo "... Remove nginx installation ...."
	yum remove nginx
	
	echo " "
	echo "... Remove cPanel hooks ..."
	/usr/bin/python ./nginxinstaller uninstall
	
else 
	echo " "
	echo "# h2nginx installer"
	echo "# Please select an action to preform :"
	echo "Usage: sh ./install.sh install | uninstall"
fi







