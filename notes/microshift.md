## Microshift
Like Openshift but targeted edge devices.

### Install
On Fedora enable Copr (Cool Other Package Repositories):
```console
$ sudo dnf copr enable -y @redhat-et/microshift
```

After that we can install `microshift`:
```console
$ sudo dnf install -y microshift
```

Configure firewal rules. There is a script, [../microshift/firewall-rules.sh]
which can be used that does the following:
```console
sudo firewall-cmd --zone=trusted --add-source=10.42.0.0/16 --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5353/udp --permanent
sudo firewall-cmd --reload
```

Enable/start microshift
```console
sudo systemctl enable microshift --now
```

Install `oc/kubectl`:
```console
$ curl -O https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/stable/openshift-client-linux.tar.gz
$ sudo tar -xf openshift-client-linux.tar.gz -C /usr/local/bin oc kubectl
```
Copy configuration:
```console
sudo cat /var/lib/microshift/resources/kubeadmin/kubeconfig > ~/.kube/config
```
Verify that pods are running:
```console
$ oc get pods -A
NAMESPACE                       NAME                                  READY   STATUS    RESTARTS   AGE
kube-system                     kube-flannel-ds-fgdpj                 1/1     Running   0          90s
kubevirt-hostpath-provisioner   kubevirt-hostpath-provisioner-gp4pn   1/1     Running   0          70s
openshift-dns                   dns-default-hlk45                     2/2     Running   0          90s
openshift-dns                   node-resolver-rfd6n                   1/1     Running   0          90s
openshift-ingress               router-default-6c96f6bc66-m6prh       1/1     Running   0          91s
openshift-service-ca            service-ca-7bffb6f6bf-dkh7t           1/1     Running   0          91s
```


### Remove
```console
$ sudo dnf remove microshift
```
