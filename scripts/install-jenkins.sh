#!/bin/sh -x

# TODO: This script supports only FreeBSD now, should also support OpenBSD

# TODO: This script should do proper error checking

## TODO: check if these variables are set
## These variables must be set outside
# export JENKINS_HOME=/home/jenkins
# export JENKINS_SLAVE_VERSION=3.9
# export JENKINS_SLAVE_URL=http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar
# export JENKINS_SHA_URL=${JENKINS_SLAVE_URL}.sha1
# export JENKINS_SLAVE_PATH=/usr/share/jenkins/slave.jar

# Create jenkins user
cat > /tmp/userentry << EOF
jenkins::::::Jenkins user:$JENKINS_HOME:/bin/sh:
EOF
adduser -w no -f /tmp/userentry && rm -f /tmp/userentry

# Install Jenkins slave and packages
pkg install -y openjdk8 gcc gmake autoconf zip wget git jq py27-pip awscli
pkg install -y automake bash libtool json-c cmocka
ln -s /usr/local/bin/bash /bin
ln -s /usr/local/bin/java /usr/bin

curl --create-dirs -sSLo ${JENKINS_SLAVE_PATH} ${JENKINS_SLAVE_URL} \
&& chmod 755 `dirname ${JENKINS_SLAVE_PATH}` && chmod 644 ${JENKINS_SLAVE_PATH}

echo "$JENKINS_SLAVE_SHA  ${JENKINS_SLAVE_PATH}" | shasum -c -
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
# cat /usr/local/scripts/safe_jenkins
