#!/bin/sh

. /etc/rc.subr

name=jenkins
start_cmd="jenkins_start"

: ${jenkins_enable="YES"}

jenkins_start()
{
   su jenkins -c /usr/local/scripts/safe_jenkins &
}

load_rc_config jenkins
run_rc_command "$1"