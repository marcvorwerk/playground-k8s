# kOps

## Prepare

### Create pyenv
```
pyenv virtualenv 3.11.6 playground-k8s-3.11.6
echo "playground-k8s-3.11.6" > .python-version
```

### Install or update requirements:
```
pip3 install -U -r requirements.txt
./install_kops.sh --upgrade
```

### Create Swift bucket to store configuration state
```
openstack container create playground-k8s-state
````

## Deploy

### Source your OpenStack RC and export KOPS_STATE_STORE
```
source ~/.config/openstack/openstack-playground.rc
export KOPS_STATE_STORE=swift://playground-k8s-state
```

### Get OpenStack Volume Type
```
openstack volume type list
```

### Deploy
```
kops create cluster \
  --cloud openstack \
  --name playground-k8s.local \
  --state ${KOPS_STATE_STORE} \
  --zones es1 \
  --network-cidr 10.0.0.0/24 \
  --image "Ubuntu 22.04 Jammy Jellyfish - Latest" \
  --master-count=3 \
  --controle-plane-count=3 \
  --node-size d1.large \
  --control-plane-size d1.large \
  --etcd-storage-type high-iops \
  --api-loadbalancer-type public \
  --os-octavia=true \
  --os-octavia-provider amphora \
  --topology private \
  --bastion \
  --ssh-public-key ~/.ssh/id_ed25519.pub \
  --networking calico \
  --dns private \
  --control-plane-volume-size 100 \
  --node-volume-size 100 \
  --os-ext-net provider
```


## Notes
```
  kubeDNS:
    provider: CoreDNS
    tolerations:
    - effect: NoSchedule
      operator: Exists
```

```
kops update cluster --name playground-k8s.local --yes --admin
```

```
kops validate cluster --wait 10m
```

```
kops edit cluster --state ${KOPS_STATE_STORE} playground-k8s.local
```

```
ubuntu@control-plane-es1-3-fhghf6:~$ kubectl get nodes
NAME                         STATUS   ROLES           AGE    VERSION
control-plane-es1-1-vsojbh   Ready    control-plane   167m   v1.27.8
control-plane-es1-2-v8hfyt   Ready    control-plane   168m   v1.27.8
control-plane-es1-3-fhghf6   Ready    control-plane   167m   v1.27.8

ubuntu@control-plane-es1-3-fhghf6:~$ #kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-

ubuntu@control-plane-es1-3-fhghf6:~$ kubectl taint nodes control-plane-es1-1-vsojbh node-role.kubernetes.io/control-plane:NoSchedule-

node/control-plane-es1-1-vsojbh untainted
ubuntu@control-plane-es1-3-fhghf6:~$ kubectl taint nodes control-plane-es1-2-v8hfyt node-role.kubernetes.io/control-plane:NoSchedule-

node/control-plane-es1-2-v8hfyt untainted
ubuntu@control-plane-es1-3-fhghf6:~$ kubectl taint nodes control-plane-es1-3-fhghf6 node-role.kubernetes.io/control-plane:NoSchedule-

node/control-plane-es1-3-fhghf6 untainted
```
