#!/usr/bin/python
# -*- coding: utf-8 -*-

import random
import string
import sys
import os
import subprocess


FNULL = open(os.devnull, 'w')

def secret_create():
    secret=''.join(random.choice(string.ascii_letters+string.digits) for i in range(16))
    print secret


def create_root_cert(subj, key_path="./k.key", cert_path="./cert.crt"):
   rc = subprocess.call(["openssl", "genrsa", "-out", key_path, "4096"], stdout=FNULL, stderr=subprocess.STDOUT)
   if rc != 0:
        return rc
   return subprocess.call(["openssl", "req", "-new", "-x509", "-key", key_path,\
        "-out", cert_path, "-days", "3650", "-subj", subj], stdout=FNULL, stderr=subprocess.STDOUT)


def cert_create(cert_dir):
    empty_subj = "/"
    create_root_cert(empty_subj, os.path.join(cert_dir,"private_key.pem"),  os.path.join(cert_dir,"root.crt"))

if sys.argv[1] == "secret":
    secret_create()
elif sys.argv[1] == "cert":
    cert_create(sys.argv[2])
