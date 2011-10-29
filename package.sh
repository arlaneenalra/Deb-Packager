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

# Look up an executable and return a path to it via RESULT or die 
is_installed() {
	EXECUTABLE=$1
	PACKAGE=$2

	RESULT=`which $1`

	if [ -z "$RESULT" ]
	then
		echo "Please install $PACKAGE and try this operation again"
		exit 2
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

# make sure we have dh_make and dpkg_buildpackage installed
is_installed dh_make dh-make
DH_MAKE=$RESULT

is_installed dpkg-buildpackage dpkg-dev
DPKG_BUILDPACKAGE=$RESULT

# Pull in configuration for the given project
. ./project.conf

# Validate that our required paramters are configured
check_defined 'AUTHOR_EMAIL' $AUTHOR_EMAIL

check_defined 'PROJECT_GIT_PATH' $PROJECT_GIT_PATH
check_defined 'PROJECT_NAME' $PROJECT_NAME

check_defined 'PACKAGING_ROOT' $PACKAGING_ROOT

# validate that the WORKING_DIR exists, create it if not
WORKING_DIR="$PACKAGING_ROOT/$PROJECT_NAME""-""$VERSION"
if [ ! -e $WORKING_DIR ]
then
	echo "Creating Working DIR"
	mkdir -p $WORKING_DIR
fi

# Build out the package dir
cd $WORKING_DIR

# Setup a default project incase we don't want to have to do all of it.
$DH_MAKE --native -s --email $AUTHOR_EMAIL

# Pull in code from our project 
(
	# sub shell to avoid lossing our current dir 
	cd $PROJECT_GIT_PATH
	GIT_WORK_TREE="$WORKING_DIR" git checkout -f
)

$DPKG_BUILDPACKAGE

