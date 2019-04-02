#!/bin/bash

haproxy_conf=$1"/haproxy.cfg"

k8s_apiserver_list=`ansible -i ../inventory/hosts masters --list-hosts | sed '1d'`
for apiserver in $k8s_apiserver_list; do
#每拿到一个apiserver地址，将$haproxy_conf中的APISERVER_PLACEHOLDER进行替换
    sed -i "0,/APISERVER_PLACEHOLDER/s//$apiserver/;0,/APISERVER_PLACEHOLDER/s//$apiserver/" $haproxy_conf
done

#删除所有占位的APISERVER_PLACEHOLDER存在的行
sed -i "/APISERVER_PLACEHOLDER/d" $haproxy_conf
