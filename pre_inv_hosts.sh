#!/bin/bash
###################生成 inventory host 文件##############
cluster_name=$1

etcd_list=`ansible -i ./inventory/hosts etcd --list-hosts | sed '1d'`
etcd_servers='etcd_servers='
for i in $etcd_list; do
    new_server='https://'$i":2379,"
    etcd_servers=$etcd_servers$new_server    
done

etcd_servers=${etcd_servers%,}

etcd_cluster=''
etcd_cluster_list=`ansible -i ./inventory/hosts etcd --ssh-common-args "-o StrictHostKeyChecking=no" -m shell -a 'echo current_info_label_ii%{{etcd_name}}=https://{{inventory_hostname}}:2380' | grep current_info_label_ii`
for i in $etcd_cluster_list; do
    new_node=`echo $i | awk -F '%' '{print $2}'`
    etcd_cluster=$etcd_cluster$new_node","
done

etcd_cluster="etcd_cluster="\"${etcd_cluster%,}\"


k8s_cert_addr=""
k8s_cert_server_list=`ansible -i ./inventory/hosts etcd,masters --list-hosts | sed '1d'`
for i in $k8s_cert_server_list; do
    k8s_cert_addr=$k8s_cert_addr\"$i\",'\n'
done

k8s_api_server=`cat ./inventory/hosts | grep "kube_apiserver=" | awk -F ':' '{print $2}' | sed $"s/\///g" `
k8s_cert_addr=$k8s_cert_addr\"$k8s_api_server\",'\n'

k8s_cluster_ip_pre=`cat ./inventory/hosts | grep service_cluster_ip | awk -F '=' '{print $2}' |  sed $'s/\"//g' | sed $'s/\'//g' | awk -F '0/' '{print $1}'`
k8s_cluster_gateway=${k8s_cluster_ip_pre}1
k8s_cert_addr=$k8s_cert_addr\"$k8s_cluster_gateway\",

#echo -e ${k8s_cert_addr}
    
service_cluster_dns="service_cluster_dns="${k8s_cluster_ip_pre}2
service_wocloud_ipam_ip="service_wocloud_ipam_ip="${k8s_cluster_ip_pre}3

current_inventory_host=./inventory/$cluster_name"_hosts"
rm -f $current_inventory_host
cp  ./inventory/hosts $current_inventory_host

sed -i $"s%^#etcd_servers=%$etcd_servers%" $current_inventory_host
sed -i $"s%^#etcd_cluster=%$etcd_cluster%" $current_inventory_host
sed -i $"s%^#service_cluster_dns=%$service_cluster_dns%" $current_inventory_host
sed -i $"s%^#service_wocloud_ipam_ip=%$service_wocloud_ipam_ip%" $current_inventory_host

rm -f ./ssl-config/kubernetes-csr.json
cp ./ssl-config/kubernetes-csr.json.template ./ssl-config/kubernetes-csr.json
sed -i  $"s/#k8s_cert_addr/$k8s_cert_addr/" ./ssl-config/kubernetes-csr.json

