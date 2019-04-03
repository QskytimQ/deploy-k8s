#workdir=`pwd`

#install ansible
#yum install ansible -y 
cluster_name=`cat inventory/hosts | grep cluster_name | awk -F '=' '{ print $2}'`
cluster_dir=/root/$cluster_name
inventory_hosts="./inventory/"$cluster_name"_hosts"
mkdir -p $cluster_dir

function pre_check() {
    record=$cluster_dir"/."$1"_done"
    if [ -f $record ];then
       return 1
    else
       return 0
    fi
}

function exec_check() {
    record="."$2"_done"
    if [ $1 -eq 0 ]; then
       date >>  $cluster_dir/$record
    else
       exit 1
    fi
}

function ansible_exec() {
    pre_check $1 
    if [ $? -eq 0 ]; then
        ansible-playbook -i $inventory_hosts --ssh-common-args "-o StrictHostKeyChecking=no" ./playbook/$1
        exec_check $? $1 
    fi
}

function ansilbe_installed_check() {
    rpm -qa ansible | grep ansible
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}


ansilbe_installed_check
if [ $? -ne 0 ]; then
    yum install ansible -y
    ansilbe_installed_check
    if [ $? -ne 0 ]; then
        echo "ansible install failed !!!"
        exit 1
    fi
fi

############################ 生成inventory host ############################
sh ./pre_inv_hosts.sh $cluster_name
if [ $? -ne 0 ]; then
    echo "Prepare inventory hosts file failed"
    exit 1
fi

############################ add new nodes OR Install Harbor #####################
if [ $# == 1 ]; then
   if [ $1 == "nodes" ]; then
       ansible_exec node_add.yaml
       ansible-playbook -i $inventory_hosts --ssh-common-args "-o StrictHostKeyChecking=no" ./playbook/cluster-ope.yaml
   elif [ $1 == "harbor" ]; then
       ./postgresql/pre_pg_hba.sh $cluster_name
       ./harbor/prepare.sh $cluster_dir
       ansible-playbook -i ./inventory/hosts --ssh-common-args "-o StrictHostKeyChecking=no" ./playbook/harbor.yaml
   else
       echo "Wrong Cmd \n Usage:\n  ./install  OR  ./install nodes OR ./install harbor"
   fi
   exit
fi


############################ 生成证书 ############################
./gencert.sh $cluster_name
if [ $? -ne 0 ]; then
    echo "ssl cert gen failed"
    exit 1
fi

############################ install ############################
#cd $workdir
#Create ssl cert AND K8s configs AND Distribute to hosts
ansible_exec prepare.yaml

#Install Etcd
ansible_exec etcd.yaml

#Install HaProxy 
ansible_exec haproxy.yaml

#Install Master 
ansible_exec master.yaml

#Config Cluster
ansible_exec cluster-config.yaml

#Install Node 
ansible_exec node.yaml

#Config Cluster ope
ansible_exec cluster-ope.yaml

#backup inventory host
#cp inventory/hosts inventory/$cluster_name.bak
