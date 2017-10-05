#!/bin/sh
#
# PROVIDE: jenkins
# REQUIRE: network

$_rc_subr_loaded . /etc/rc.subr

name=jenkins
start_cmd="jenkins_start"

: ${jenkins_enable="YES"}

jenkins_start()
{
   su jenkins -c /usr/local/scripts/safe_jenkins &
}

load_rc_config $name
run_rc_command "$1"
