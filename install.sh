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

#
#	Proceed with the installation
#

if [ "$1" == "install" ]; then 

	echo " h2nginx installer :::::: "
	echo " "

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
	/usr/bin/python ./nginxinstaller uninstall

else 
	echo " "
	echo "# h2nginx installer"
	echo "# Please select an action to preform :"
	echo "Usage: sh ./install.sh install | uninstall"
fi
