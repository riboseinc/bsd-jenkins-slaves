#!/bin/sh

daemon="/usr/local/scripts/safe_jenkins"
daemon_user="jenkins"

. /etc/rc.d/rc.subr

rc_bg=YES

pexp="java.*slave.jar.*"

rc_cmd $1

