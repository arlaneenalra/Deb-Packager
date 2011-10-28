#!/bin/sh


usage() {
	echo "Usage: package.sh <version number>"
	exit 1;
}

# Avoid duplication of defined checks
check_defined() {
	VAR_NAME=$1
	VAR=$2
	
	if [ -z "$VAR" ]
	then
		echo "$VAR_NAME must be defined in project.conf" 
		exit 1
	fi
}

if [ ! -e 'project.conf' ]
then
	echo 'No project.conf file found in the current directory!' ;
	exit 1;
fi

# Make sure that we were given a version number
VERSION="$1"
if [ -z "$VERSION" ]
then
	usage
fi

# Setup configuration defaults

# Where will we find git?
GIT_PATH=`which git`

# Pull in configuration for the given project
. ./project.conf

# Validate that our required paramters are configured
check_defined 'AUTHOR' $AUTHOR

check_defined 'PROJECT_GIT_URL' $PROJECT_GIT_URL
check_defined 'PROJECT_NAME' $PROJECT_NAME

check_defined 'PACKAGING_ROOT' $PACKAGING_ROOT

# Build out the package dir

