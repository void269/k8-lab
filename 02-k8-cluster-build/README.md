# Kubernetes Lab with Terraform (AWS)

## Overview

This project deploys a multi-node Kubernetes cluster on AWS using
Terraform and kubeadm.

-   1 Kubernetes Control Plane
-   2 Kubernetes Worker Nodes
-   Automated cluster bootstrap
-   Automated worker node join
-   AWS VPC networking

## Project Structure

``` text
02-k8-cluster-build/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── manager.sh.tftpl
├── worker.sh.tftpl
├── build.sh
├── destroy.sh
└── README.md
```

## Requirements

-   Terraform 1.5+
-   AWS CLI
-   AWS account
-   Ubuntu AMI
-   SSH key pair
-   Git Bash (recommended on Windows)

## Deploy

``` bash
./build.sh
./run.sh
```

## Verify

``` bash
kubectl get nodes
```

Expected:

``` text
k8-manager
k8-worker-1
k8-worker-2
```

## Destroy

``` bash
./destroy.sh
```

## Troubleshooting

``` bash
sudo cloud-init status --long
sudo tail -200 /var/log/cloud-init-output.log
kubectl get nodes
kubectl get pods -A
```

## License

Educational use.