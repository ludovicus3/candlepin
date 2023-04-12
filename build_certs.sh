#!/bin/bash

TRUSTSTORE=/etc/candlepin/certs/truststore
KEYSTORE=/etc/candlepin/certs/keystore

PASSWORD_DIR=/var/run/secrets/passwords
KEYSTORE_PASSWORD=$PASSWORD_DIR/KEYSTORE_PASSWORD
TRUSTSTORE_PASSWORD=$PASSWORD_DIR/TRUSTSTORE_PASSWORD

function add_key {
  local pkcs12=/tmp/pkcs12
  local alias=$1
  local cert=$2
  local key=$3
  local ca=$4

  openssl \
    pkcs12 \
    -export \
    -in $cert \
    -inkey $key \
    -out $pkcs12 \
    -name $alias \
    -CAfile $ca \
    -password file:$KEYSTORE_PASSWORD

  keytool -importkeystore \
    -noprompt \
    -srckeystore $pkcs12 \
    -srcstorepass:file $KEYSTORE_PASSWORD \
    -destkeystore $KEYSTORE \
    -deststorepass:file $KEYSTORE_PASSWORD \
    -srcalias $alias \
    -destalias $alias \
    -J-Dcom.redhat.fips=false

  rm -f $pkcs12

  chown root:tomcat $KEYSTORE
  chmod 0640 $KEYSTORE
}

function add_trust {
  local alias=$1
  local certificate=$2

  keytool \
    -import \
    -noprompt \
    -storetype pkcs12 \
    -keystore $TRUSTSTORE \
    -alias $alias \
    -file $certificate \
    -storepass:file $TRUSTSTORE_PASSWORD \
    -J-Dcom.redhat.fips=false

  chown root:tomcat $TRUSTSTORE
  chmod 0640 $TRUSTSTORE
}

add_trust candlpin-ca /var/run/secrets/tomcat/ca.crt
add_trust atemis-client /var/run/secrets/foreman/tls.crt

add_key tomcat /var/run/secrets/tomcat/tls.crt /var/run/secrets/tomcat/tls.key /var/run/secrets/tomcat/ca.crt
