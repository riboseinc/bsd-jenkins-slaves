#!/bin/sh

daemon="/usr/local/scripts/safe_jenkins"

daemon_user="jenkins"
rc_bg=YES

rc_start() {
        ${daemon}
}

. /etc/rc.d/rc.subr

rc_cmd $1
