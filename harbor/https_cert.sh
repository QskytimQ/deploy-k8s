#!/bin/bash

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Wocloud/OU=Wocloud/CN={{ harbor_vip }}" \
  -key ca.key \
  -out ca.crt

openssl genrsa -out server.key 4096

openssl req -sha512 -new \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Wocloud/OU=Wocloud/CN={{ harbor_vip }}" \
  -key server.key \
  -out server.csr 

openssl x509 -req -sha512 -days 3650 \
  -extfile v3.ext \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -in server.csr \
  -out server.crt

openssl x509 -inform PEM -in server.crt -out server.cert
