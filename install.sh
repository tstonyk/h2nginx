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

if [ ! -f "/usr/local/cpanel/version" ]; then
	echo "cPanel is not installed on this server";
	exit 0;
fi

#### Private functions
function _addRepo {

if [ ! -f "/etc/yum.repos.d/centalt.repo" ]; then 
	echo "[CentALT]" >> /etc/yum.repos.d/centalt.repo
	echo "name=CentALT Packages for Enterprise Linux 5 - $basearch" >> /etc/yum.repos.d/centalt.repo
	echo "baseurl=http://centos.alt.ru/repository/centos/5/$basearch/" >> /etc/yum.repos.d/centalt.repo
	echo "enabled=0" >> /etc/yum.repos.d/centalt.repo
	echo "gpgcheck=0" >> /etc/yum.repos.d/centalt.repo
fi
}

function _removeRepo {
	if [ -f "/etc/yum.repos.d/centalt.repo" ]; then 
			rm -f /etc/yum.repos.d/centalt.repo
	fi
}

function _rpmforge {
	               #
               # Create the rpmforge.repos file in /etc/yum.repos.d/
               #-------------------------------------------------
               echo "[rpmforge]" > /etc/yum.repos.d/rpmforge.repo
               echo "name = Red Hat Enterprise $releasever - RPMforge.net - dag" >> /etc/yum.repos.d/rpmforge.repo
               echo "baseurl = http://apt.sw.be/redhat/el5/en/$basearch/dag" >> /etc/yum.repos.d/rpmforge.repo
               echo "mirrorlist = http://rh-mirror.linux.iastate.edu/pub/dag/redhat/el5/en/mirrors-rpmforge" >> /etc/yum.repos.d/rpmforge.repo
               echo "enabled = 0" >> /etc/yum.repos.d/rpmforge.repo
               echo "gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag" >> /etc/yum.repos.d/rpmforge.repo
               echo "gpgcheck = 0" >> /etc/yum.repos.d/rpmforge.repo

}
function _removerpmforge {
	echo "... Removing RPMForge installation ..."
	rm -f /etc/yum.repos.d/rpmforge.repo
}
function _checkPython {
	$easy_install = $(which easy_install)
	
	if [ ! -f "$easy_install" ]; then
		yum -y install python-setuptools
	fi
}
#
#	Proceed with the installation
#

if [ "$1" == "install" ]; then 
	cd /usr/src/h2nginx
	
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
	
	echo "... Check for python-setup tools install ..."
	_checkPython
	
	echo "... Install PyYAML ..."
	_rpmforge
	yum --enablerepo=rpmforge -y install libyaml
	easy_install PyYAML  
	_removerpmforge
	
	echo "... Proceed with the installation ..."
	/usr/bin/python ./nginxinstaller install
	
elif [ "$1" == "uninstall" ]; then
	echo "... Remove CentALT repository ..."
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