#!/bin/bash

path=$1

k8s_masters_list=`ansible -i ../inventory/hosts masters --list-hosts | sed '1d'`
for master in $k8s_masters_list; do
    echo "  - ip: $master" >> $path/kube-controller-manager-endpoint.yaml
    echo "    targetRef:" >> $path/kube-controller-manager-endpoint.yaml
    echo "      kind: Node" >> $path/kube-controller-manager-endpoint.yaml
    echo "      name: $master0" >> $path/kube-controller-manager-endpoint.yaml

    echo "  - ip: $master" >> $path/kube-scheduler-endpoint.yaml
    echo "    targetRef:" >> $path/kube-scheduler-endpoint.yaml
    echo "      kind: Node" >> $path/kube-scheduler-endpoint.yaml
    echo "      name: $master0" >> $path/kube-scheduler-endpoint.yaml
done
