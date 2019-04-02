############################ 生成证书 ############################
cluster_name=$1
ssl_dir=/root/$cluster_name/ssl
mkdir -p $ssl_dir

if [ -f $ssl_dir/.done ];then
    exit
fi

cp ssl-config/* $ssl_dir
cp cfssl/* /usr/local/bin/
cd $ssl_dir

#生成CA
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

#TODO 自动生成kubernetes-csr.json中，etcd、master服务器列表

#kubernetes证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

#admin证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

#kube-controller-manager证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

#kube-controller-manager证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

#kube-proxy证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy

#kube aggregator证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  aggregator-csr.json | cfssljson -bare aggregator

#service account证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  service-account-csr.json | cfssljson -bare service-account 

#record
date > $ssl_dir/.done
