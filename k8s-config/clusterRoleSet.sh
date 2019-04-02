#!/bin/bash
OLD_IFS="$IFS"
IFS=$'\n'
for node in `kubectl get nodes | sed '1d'`
do
    role=`echo $node | awk -F ' ' '{print $3}'`
    if [ $role == "<none>" ]
    then
       nodename=`echo $node | awk -F ' ' '{print $1}'`
       kubectl label node $nodename kubernetes.io/role=node
    fi
done
IFS="$OLD_IFS"
