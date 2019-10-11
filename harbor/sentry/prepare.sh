#!/bin/bash

cluster_dir=$1
harbor_vip=$2
harbor_protocol=$3
harbor_admin_password=$4

mkdir -p $cluster_dir"/harbor/sentry"

sentry_conf=$cluster_dir"/harbor/sentry/config.toml"

ansible 127.0.0.1 -i ./inventory/hosts -m template -a "src=./harbor/sentry/config.toml dest=$sentry_conf" -e "harbor_vip=$harbor_vip" -e "harbor_protocol=$harbor_protocol" -e "harbor_admin_password=$harbor_admin_password"

harbor_ip_list=`ansible -i ./inventory/hosts harbor --list-hosts | sed '1d'`
for harbor_ip in $harbor_ip_list; do
#每拿到一个harbor_ip地址，将$sentry_conf中的HARBORIP_PLACEHOLDER进行替换
    sed -i "0,/HARBORIP_PLACEHOLDER/s//$harbor_ip/" $sentry_conf
done
