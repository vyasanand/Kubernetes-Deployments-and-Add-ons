# Create a Kubernetes cluster using kubeadm
In this demo we will setup a 3 node Kubernetes cluster using kubeadm

## Pre-requirements

#### Hardware and OS
Below are the pre-requirements that we will perform in order to install the cluster without any issues. Check the [kubernetes offical guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for detailed list of pre-requirements.

```shell
01) RHEL 7
02) 2GB+ of RAM per machine
03) 2CPUs or more per machine
04) Full network connectivity between all machines in the cluster
05) Unique hostname, MAC address, and product_uuid for every node
06) Certain ports are open on your machines (Current setup has no restrictions on the ports, not recommended for prod)
07) Swap disabled
08) Verify br_netfilter module is loaded
09) Linux nodes iptables to correctly see bridged traffic
10) Installing Runtime (We will use Docker as our container runtime)
```
