# Base container that is used for both building and running the app
FROM quay.io/centos/centos:stream8
ARG JAVA_VERSION="11"

ADD theforeman.repo /etc/yum.repos.d/theforeman.repo

#RUN rpm --import https://yum.theforeman.org/RPM-GPG-KEY-foreman

RUN \
  dnf upgrade -y && \
  dnf module enable pki-core pki-deps -y && \
  dnf install candlepin -y && \
  dnf clean all

RUN date -u > BUILD_TIME

EXPOSE 8080/tcp
EXPOSE 8443/tcp

ENTRYPOINT ["/usr/sbin/init"]
