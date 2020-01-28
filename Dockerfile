FROM java:8
VOLUME /tmp

ADD patch-cert-store.sh .

RUN chmod a+x patch-cert-store.sh 

RUN ./patch-cert-store.sh