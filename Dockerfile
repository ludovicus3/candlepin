# Base container that is used for both building and running the app
FROM quay.io/centos/centos:stream8
ARG JAVA_VERSION="11"

ADD theforeman.repo /etc/yum.repos.d/theforeman.repo

#RUN rpm --import https://yum.theforeman.org/RPM-GPG-KEY-foreman

RUN \
  dnf upgrade -y && \
  dnf module enable pki-core pki-deps -y && \
  dnf install candlepin postgresql openssl -y && \
  dnf clean all

ADD build_certs.sh /usr/local/bin/build_certs

ADD etc/tomcat/cert-roles.properties /etc/tomcat/cert-roles.properties
ADD etc/tomcat/login.config /etc/tomcat/login.config
ADD etc/tomcat/tomcat.conf /etc/tomcat/tomcat.conf
ADD etc/tomcat/conf.d/jaas.conf /etc/tomcat/conf.d/jaas.conf 

RUN date -u > BUILD_TIME

EXPOSE 8080/tcp
EXPOSE 8443/tcp

ENTRYPOINT ["/usr/sbin/init"]
