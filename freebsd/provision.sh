#!/bin/sh
export JENKINS_HOME=/home/jenkins
cat > /tmp/userentry << EOF
jenkins::::::Jenkins user:$JENKINS_HOME:/bin/sh:
EOF
adduser -w no -f /tmp/userentry && rm -f /tmp/userentry

pkg install -y openjdk8 gcc gmake autoconf zip wget git jq py27-pip awscli
pkg install -y automake bash libtool json-c cmocka
ln -s /usr/local/bin/bash /bin
ln -s /usr/local/bin/java /usr/bin

export JENKINS_SLAVE_VERSION=3.9
export JENKINS_SLAVE_URL=http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar
export JENKINS_SHA_URL=${JENKINS_SLAVE_URL}.sha1
export JENKINS_SLAVE_PATH=/usr/share/jenkins/slave.jar
export JENKINS_SLAVE_SHA=$(curl ${JENKINS_SHA_URL})

curl --create-dirs -sSLo ${JENKINS_SLAVE_PATH} ${JENKINS_SLAVE_URL} \
&& chmod 755 `dirname ${JENKINS_SLAVE_PATH}` && chmod 644 ${JENKINS_SLAVE_PATH} 

echo "$JENKINS_SLAVE_SHA  ${JENKINS_SLAVE_PATH}" | shasum -c - 
if [ $? -ne 0 ]; then exit 1 ; fi

mkdir /scripts
wget --no-check-certificate -O /scripts/jenkins-slave https://github.com/riboseinc/bsd-jenkins-slaves/raw/master/scripts/jenkins-slave
chmod 755 /scripts/jenkins-slave
cat > /scripts/safe_jenkins << EOF
#!/bin/sh

while true; do
   JENKINS_URL=CCCC JENKINS_TUNNEL=DDDD JNLP_PROTOCOL_OPTS="EEEE" /scripts/jenkins-slave AAAA BBBB
done
EOF
chmod 755 /scripts/safe_jenkins
sed -i .bak -e "s/AAAA/$JENKINS_SLAVE_NAME/g" -e "s/BBBB/$JENKINS_SLAVE_SECRET/g" -e "s|CCCC|$JENKINS_URL|g" -e "s/DDDD/$JENKINS_TUNNEL/" -e "s/EEEE/$JENKINS_JNLP_PROTOCOL_OPTS/" /scripts/safe_jenkins
rm -f /scripts/safe_jenkins.bak

cat > /tmp/j.b64 << EOF
begin-base64 755 jenkins.sh
IyEvYmluL3NoCgouIC9ldGMvcmMuc3VicgoKbmFtZT1qZW5raW5zCnN0YXJ0X2NtZD0iamVua2lu
c19zdGFydCIKCjogJHtqZW5raW5zX2VuYWJsZT0iWUVTIn0KCmplbmtpbnNfc3RhcnQoKQp7CiAg
IHN1IGplbmtpbnMgLWMgL3NjcmlwdHMvc2FmZV9qZW5raW5zICYKfQoKbG9hZF9yY19jb25maWcg
amVua2lucwpydW5fcmNfY29tbWFuZCAiJDEiCg==
====
EOF
b64decode -o /usr/local/etc/rc.d/jenkins.sh /tmp/j.b64 && rm -f /tmp/j.b64
chmod 755 /usr/local/etc/rc.d/jenkins.sh
reboot
