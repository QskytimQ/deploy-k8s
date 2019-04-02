#!/bin/bash
cluster_name=$1

harbor_list=`ansible -i ./inventory/hosts harbor --list-hosts | sed '1d'`
cp ./postgresql/pg_hba.conf /root/$cluster_name/pg_hba.conf
for i in $harbor_list; do
    new="host    replication     replica         $i/32          trust"
    echo $new >> /root/$cluster_name/pg_hba.conf
done

master_ip=`cat ./inventory/hosts | grep harbor -C 2 | grep MASTER | awk -F ' ' '{print $1}'`
echo "#!/bin/sh" > /root/$cluster_name/pg_basebackup.sh
echo "pg_basebackup -h $master_ip -U replica -F p -X stream -P -R -D {{ postgresql_data_dir }}" >> /root/$cluster_name/pg_basebackup.sh

