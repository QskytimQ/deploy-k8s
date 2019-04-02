# Kubernetes And Harbor Deploy
This project is to deploy Kubernetes and Harbor with HA

## Usage：
#### 1. Config
config ansible inventory file
```
./inventory/hosts
```
#### 2. Deploy
##### 2.1 Deploy Kubernetes cluster
```
./install.sh
```
##### 2.2 Add Nodes to a deployed Kubernetes cluster
```
./install.sh nodes
```
##### 2.3 Deploy harbor with HA
```
./install.sh harbor
```

