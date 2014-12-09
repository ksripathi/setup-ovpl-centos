#!/bin/bash
# Script to setup a fresh installation of CentOS to run OVPL
# Installs: Dependencies: python-devel, git, pip; mongodb; openvz.


LOGGFILE="setup-ovpl.log"
DATE=$(date)

if [[ -f $LOGGFILE ]];then
	echo "============================================="
	echo "logpath = setup-ovpl-centos/scripts/$LOGGFILE"
	echo "=============================================="
else
	touch $LOGGFILE
	echo "============================================="
	echo "logpath = setup-ovpl-centos/scripts/$LOGGFILE"
	echo "============================================="
fi

# check if script is run as root
if [[ $UID -ne 0 ]]; then
  echo ""
  echo "$0 must be run as root!"
  echo "Exiting.."
  exit 1
fi

# check if meta directory exists
if [[ ! -d "../meta" ]]; then
  echo ""
  echo "You don't have the necessary files."
  echo "Please contact the author of the script."
  exit 1
fi
# read proxy settings from config file
if [[ -f "config.sh" ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Reading config.sh file for proxy settings" 2>&1 | tee -a $LOGGFILE
	source ./config.sh
	if [[ -n $http_proxy ]]; then
  		
  		export http_proxy=$http_proxy
  		echo "[[$DATE:: $0 :: Line $LINENO::]] export http_proxy = $http_proxy" 2>&1 | tee -a $LOGGFILE
	fi
	if [[ -n $https_proxy ]]; then
  		export https_proxy=$https_proxy
  		echo "[[$DATE:: $0 :: Line $LINENO::]] export https_proxy = $https_proxy" 2>&1 | tee -a $LOGGFILE
	fi
else
	echo "[[$DATE:: $0 :: Line $LINENO::]] config.sh file not exist" 2>&1 | tee -a $LOGGFILE
	exit 1
fi

#updating system
echo ""
echo "========================== UPDATING SYSTEM ================================"
echo "[[$DATE:: $0 :: Line $LINENO::]] Updating System...." 2>&1 | tee -a $LOGGFILE
yum update -y
if [[ $? -ne 0 ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Error in updating system " 2>&1 | tee -a $LOGGFILE
	exit 1
else
	echo "" 	
	echo "[[$DATE:: $0 :: Line $LINENO::]] System updation complete.." 2>&1 | tee -a $LOGGFILE
	echo ""
fi


if [[ -f "install_dependencies.sh" ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Invoking install_dependencies.sh" 2>&1 | tee -a $LOGGFILE
	./install_dependencies.sh
	if [ $? -ne 0 ]; then
 		echo ""
  		echo "[[$DATE:: $0 :: Line $LINENO::]] Error installing dependencies. Quitting!" 2>&1 | tee -a $LOGGFILE
  		exit 1
	fi
else
	echo "[[$DATE:: $0 :: Line $LINENO::]] install_dependencies.sh file not exist" 2>&1 | tee -a $LOGGFILE
	exit 1
fi

if [[ -f "install_openvz.sh" ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Invoking install_openvz.sh" 2>&1 | tee -a $LOGGFILE
	./install_openvz.sh
	if [ $? -ne 0 ]; then
 		echo ""
  		echo "[[$DATE:: $0 :: Line $LINENO::]] Error installing openvz. Quitting! See log file" 2>&1 | tee -a $LOGGFILE
  		exit 1
	fi
else
	echo "[[$DATE:: $0:: Line $LINENO::]] install_openvz.sh file not exist" 2>&1 | tee -a $LOGGFILE
	exit 1
fi

if [[ -f "install_mongodb.sh" ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Invoking install_mongodb.sh" 2>&1 | tee -a $LOGGFILE
	./install_mongodb.sh
	if [ $? -ne 0 ]; then
 		echo ""
  		echo "[[$DATE:: $0 :: Line $LINENO::]] Error installing mongodb. Quitting! " 2>&1 | tee -a $LOGGFILE
  		exit 1
	fi
else
	echo "[[$DATE:: $0 :: Line $LINENO::]] install_mongodb.sh file not exist" 2>&1 | tee -a $LOGGFILE
	exit 1
fi

if [[ -f "install_ovpl.sh" ]];then
	echo "[[$DATE:: $0 :: Line $LINENO::]] Invoking install_ovpl.sh" 2>&1 | tee -a $LOGGFILE
	./install_ovpl.sh
	if [ $? -ne 0 ]; then
 		echo ""
  		echo "[[$DATE:: $0 :: Line $LINENO::]] Error installing ovpl. Quitting! " 2>&1 | tee -a $LOGGFILE
  		exit 1
	fi
else
	echo "[[$DATE:: $0 :: Line $LINENO::]] install_ovpl.sh file not exist" 2>&1 | tee -a $LOGGFILE
	exit 1
fi

exit 0
