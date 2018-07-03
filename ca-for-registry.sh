#!/usr/bin/bash
# create private registry for your docker hub



# step1, generate a root certificate let self as CA

# generate private key of CA
sudo openssl genrsa -out ca.key 2048

# genearate certificate "ca.crt"
# "CN=name" mean to owner and user is same
sudo openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/C=CN/CN=name"




# step2, client use step1 genarate certificate "ca.crt"

# genarate ptivte key
sudo openssl genrsa -out server.key 2048

# genarate signed file for request
sudo openssl req -new -key server.key -out server.csr -subj "/C=CN/CN=192.168.33.10"

# genarate certificate
# "subjectAltName"  param of values "IP:ip addres,DNS:your direacry name", this can choose one of them
# now my vm ip is "192.168.33.10"
# param "x509" is version 3 of new ,this to do can alow many machine to use.
sudo openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile <(printf "subjectAltName=IP:192.168.33.10") -out server.crt



# step3, install CA certificate

# start your private registry
# EGISTRY_HTTP_TLS_CERTIFICATE certificate file of path
# REGISTRY_HTTP_TLS_KEY  private key of path
sudo docker run -d -p 5000:5000 --name docker-registry \
-v /home/docker-registry:/home/docker-registry \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/home/docker-registry/server.crt \
-e REGISTRY_HTTP_TLS_KEY=/home/docker-registry/server.key \
registry:2

# back 
sudo cp /etc/pki/tls/certs/ca-bundle.crt{,.backup}

# import root certificate
# until , you can push or pull from your privte registry
sudo cat ca.crt >> /etc/pki/tls/certs/ca-bundle.crt



