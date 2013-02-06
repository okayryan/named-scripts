#!/bin/bash

# checkzones.sh
# Ryan Kohler
# source.kohlerville@gmail.com
# 01.2013
# An OSI license hasn't been chosen, but BSD or MIT probably

# This script will go through and check zone files to make sure
# they have a valid configuration using named-checkzone
# It will error out on the first problem it sees.
# Enter a list of zones you want to do at the bottom of the file

# Exit codes:
# 1 - wrong number of parameters in a function
# 2 - error in one of the zone files

# Programs - place the full path of your programs here
BASENAME=/bin/basename
LS=/bin/ls
NAMEDCHECKZONE=/usr/sbin/named-checkzone

# Variables
SUFFIX=.zone

# checkzone() runs the named-checkzone on a
# specified zone name and domain name
# parameters:
# zonename (IE. source.kohlerville.com.zone
# domainname (IE. source.kohlerville.com)
# location (IE. /var/named/chroot/var/named/primary/internal
function checkzone()
{
	if [ ${#} -ne 3 ]
	then
		echo "Exiting, checkzone() takes \
		only three arguments. Got ${#}"
		exit 1
	fi

	zonename=${1}
	domainname=${2}
	location=${3}

	# run it in quiet mode first
	${NAMEDCHECKZONE} -q -w ${location} ${zonename} ${domainname}

	# compare the return code to see if we need to run it
	# again to display the error to the user
	if [ ${?} -ne 0 ]
	then
		${NAMEDCHECKZONE} -w ${location} ${zonename} ${domainname}
		exit 2
	fi
}

function checkzonefiles()
{
	if [ ${#} -ne 1 ]
	then
		echo "Exiting, checkzonefiles() takes \
		only one argument. Got ${#}"
		exit 1
	elif [ -d ${1} ]
	then
		echo "Exiting, checkzonefiles() takes \
		only one argument that needs to be a \
		directory. Got ${1}"
		exit 1
	fi

	zoneloc=${1}
	# for loop through the files in zoneloc
	shopt -s nullglob
	for zonename in ${zoneloc}/*
	do
		# Add as many case staments as you like
		# for each special case zone you may have
		# Here are two examples
		case "${base}" in
		192.168 | lightsout.source.kohlerville.com)
			# Special case for reverse and forward zones
			checkzone lightsout.source.kohlerville.com ${zonename} ${zoneloc}
		*)
			# This works for zone files that are named
			# domainname.zone
			base=`${BASENAME} ${zonename} ${SUFFIX}`
			checkzone ${base} ${zonename} ${zoneloc}
		;;
		esac
	done
}

# Location of zone files as an example
ZONELOC=/var/named/chroot/var/named/primary/internal
checkzonefiles ${ZONELOC}
