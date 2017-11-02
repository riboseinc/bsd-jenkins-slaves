#!/bin/sh -x

# TODO: This script should do proper error checking

## TODO: check if these variables are set
## These variables must be set outside
# export JENKINS_HOME=/home/jenkins
# export JENKINS_SLAVE_VERSION=3.9
# export JENKINS_SLAVE_URL=http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar
# export JENKINS_SHA_URL=${JENKINS_SLAVE_URL}.sha1
# export JENKINS_SLAVE_PATH=/usr/share/jenkins/slave.jar

# Source root's .profile to get PKG_PATH set
. /root/.profile

# Update system
pkgin update
pkgin -y full-upgrade

pkgin -y install mozilla-rootcerts
mozilla-rootcerts install

# Install Jenkins slave and packages
pkgin -y install bash bash-completion openjdk8 gcc git
pkgin -y install py36-pip-9.0.1 gmake libtool libevent llvm boost autoconf automake jq
pkgin -y install json-c cmocka
pip3.6 install --trusted-host pypi.python.org awscli
ln -s /usr/pkg/java/openjdk8/bin/java /usr/bin/java
ln -s /usr/pkg/bin/bash /bin/bash
ln -s /usr/pkg/bin/python3.6 /usr/bin/python

# Create jenkins user
# password is vagrantslave , already encrypted
useradd -m -p '$sha1$20039$aVpiBSpR$HhZAd60PRq4EjB.e06j/xnnUmAQz' -s /usr/pkg/bin/bash -g 100 -u 100 jenkins

curl --create-dirs -sSLo ${JENKINS_SLAVE_PATH} ${JENKINS_SLAVE_URL} \
&& chmod 755 `dirname ${JENKINS_SLAVE_PATH}` && chmod 644 ${JENKINS_SLAVE_PATH}

echo "$JENKINS_SLAVE_SHA  ${JENKINS_SLAVE_PATH}" | sha1 -c
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
