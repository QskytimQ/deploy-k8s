#!/bin/sh

# #############################################
# Copyright (c) 2019-2029 suxiaolin. All rights reserved.
# #############################################
#
# Name:  prepare.sh
# Date:  2019-04-02 15:09
# Author:   suxiaolin
# Email:   linxxnil@126.com
# Desc:  
#
#

cluster_dir=$1
harbor_dir=$cluster_dir"/harbor"

mkdir -p $harbor_dir

if [ ! -f $harbor_dir/ui_secret ];then
    ui_secret=`python ./harbor/secret_create.py secret`
    echo -n $ui_secret > $harbor_dir/ui_secret
fi

if [ ! -f $harbor_dir/jobservice_secret ];then
    jobservice_secret=`python ./harbor/secret_create.py secret`
    echo -n $jobservice_secret > $harbor_dir/jobservice_secret
fi

if [ ! -f $harbor_dir/secretkey ];then
    jobservice_secret=`python ./harbor/secret_create.py secret`
    echo -n $jobservice_secret > $harbor_dir/secretkey
fi

if [ ! -f $harbor_dir"/private_key.pem" ];then
    python ./harbor/secret_create.py cert $harbor_dir
fi

harbor_https_cert_dir=$harbor_dir'/https'
mkdir -p $harbor_https_cert_dir

harbor_https_v3_ext=$harbor_https_cert_dir'/v3.ext'

harbar_vip=`cat ./inventory/hosts | grep harbor_vip | sed s/\'//g | sed s/\"//g | awk -F '='  '{print $2}'`

ansible 127.0.0.1 -m template -a "src=./harbor/v3.ext.template dest=$harbor_https_v3_ext" -e "harbor_vip=$harbar_vip"

harbor_list=`ansible -i ./inventory/hosts harbor --list-hosts | sed '1d'`
num=2
for harbor_ip in $harbor_list; do
    new='IP.'$num"="$harbor_ip
    echo $new >> $harbor_https_v3_ext
    num=`expr $num + 1`  
done

ansible 127.0.0.1 -m template -a "src=./harbor/https_cert.sh dest=$harbor_https_cert_dir mode=0755" -e "harbor_vip=$harbar_vip"

ansible 127.0.0.1 -m shell -a "./https_cert.sh chdir=$harbor_https_cert_dir"

