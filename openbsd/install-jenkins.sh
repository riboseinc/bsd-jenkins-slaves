#!/bin/sh -x

# TODO: This script should do proper error checking

## TODO: check if these variables are set
## These variables must be set outside
# export JENKINS_HOME=/home/jenkins
# export JENKINS_SLAVE_VERSION=3.9
# export JENKINS_SLAVE_URL=http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar
# export JENKINS_SHA_URL=${JENKINS_SLAVE_URL}.sha1
# export JENKINS_SLAVE_PATH=/usr/share/jenkins/slave.jar

# Create jenkins user
cat > /etc/adduser.conf << EOF
verbose = 1
defaultpasswd = "no"
encryptionmethod = "auto"
dotdir = "/etc/skel"
send_message = "no"
message_file = "/etc/adduser.message"
config = "/etc/adduser.conf"
logfile = "/var/log/adduser"
home = "/home"
path = ('/bin', '/usr/bin', '/usr/local/bin')
shellpref = (''sh', 'ksh', 'nologin')
defaultshell = "sh"
defaultgroup = "USER"
uid_start = 1000
uid_end = 2147483647
defaultclass = "default"
login_classes = ('default', 'daemon', 'staff', 'authpf', 'pbuild', 'bgpd', 'unbound')
EOF

adduser -unencrypted -batch jenkins users 'Jenkins Slave' vagrantslave

pkg_add jre bash
ln -s /usr/local/jre-1.8.0/bin/java /usr/bin
ln -s /usr/local/bin/bash /bin
pkg_add gmake libtool libevent autoconf-2.69p2 automake-1.15p0 python-3.5.2p2 llvm boost git

curl --create-dirs -sSLo ${JENKINS_SLAVE_PATH} ${JENKINS_SLAVE_URL} \
&& chmod 755 `dirname ${JENKINS_SLAVE_PATH}` && chmod 644 ${JENKINS_SLAVE_PATH}

echo "$JENKINS_SLAVE_SHA  ${JENKINS_SLAVE_PATH}" | sha1 -c -
if [ $? -ne 0 ]; then exit 1 ; fi

# Create jenkins start script
cat > /usr/local/scripts/safe_jenkins << EOF
#!/bin/sh

export JENKINS_URL=${JENKINS_URL}
export JENKINS_TUNNEL=${JENKINS_TUNNEL}
export JENKINS_SECRET=${JENKINS_SECRET}
export JNLP_PROTOCOL_OPTS=${JNLP_PROTOCOL_OPTS}

# while true; do
/usr/local/scripts/jenkins-slave
# done
EOF

chmod 755 /usr/local/scripts/safe_jenkins
