# Kubernetes Lab with Terraform (AWS)

## Overview

This project deploys a multi-node Kubernetes cluster on AWS using
Terraform from the ground up.

1. VPC build
2. Public and Privet Subnets created and attached
3. Internet Gateway created and attached
4. 3 Ubuntu EC2 t3.medium instances deployed
5. Kubernetes installed on EC2 instances
6. Control Plan Node setup and Kubernetes Cluster created
7. Worker Nodes setup and joined to the Cluster

## Project Structure

``` text
02-k8-cluster-build/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── control-plane.sh.tftpl
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
k8-control-plane
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

## Architectural Diagram


```mermaid
flowchart TB

    Internet((Internet))

    subgraph AWS["AWS Region (us-east-1)"]

        subgraph VPC["VPC"]

            subgraph PublicSubnet["Public Subnet"]

                control plane["EC2<br/>Kubernetes control plane<br/>(Control Plane)<hr/>Ubuntu<br/>containerd<br/>kubeadm<br/>kubectl<br/>kubelet"]

                Worker1["EC2<br/>Kubernetes Worker 1<hr/>Ubuntu<br/>containerd<br/>kubeadm<br/>kubelet"]

                Worker2["EC2<br/>Kubernetes Worker 2<hr/>Ubuntu<br/>containerd<br/>kubeadm<br/>kubelet"]

            end
        end
    end

    Internet --> control plane

    control plane <-->|Kubernetes API| Worker1
    control plane <-->|Kubernetes API| Worker2

    classDef control plane fill:#1976d2,color:#fff,stroke:#0d47a1,stroke-width:2px;
    classDef worker fill:#388e3c,color:#fff,stroke:#1b5e20,stroke-width:2px;

    class control plane control plane;
    class Worker1,Worker2 worker;
```