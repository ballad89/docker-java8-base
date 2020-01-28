#!/bin/bash


set -e

mydir=/tmp
truststore=${JAVA_HOME}/jre/lib/security/cacerts
storepassword=changeit

curl -sS "https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem" > ${mydir}/rds-combined-ca-bundle.pem
awk 'split_after == 1 {n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1}{print > "rds-ca-" n ".pem"}' < ${mydir}/rds-combined-ca-bundle.pem

for CERT in rds-ca-*; do
  alias=$(openssl x509 -noout -text -in $CERT | perl -ne 'next unless /Subject:/; s/.*(CN=|CN = )//; print')
  echo "Importing $alias"
  keytool -import -file ${CERT} -alias "${alias}" -storepass ${storepassword} -keystore ${truststore} -noprompt
  rm $CERT
done


mkdir /usr/local/share/ca-certificates/aws
mv ${mydir}/rds-combined-ca-bundle.pem /usr/local/share/ca-certificates/aws

openssl x509 -in /usr/local/share/ca-certificates/aws/rds-combined-ca-bundle.pem -inform PEM -out /usr/local/share/ca-certificates/aws/rds-ca-2019-root.crt

update-ca-certificates
