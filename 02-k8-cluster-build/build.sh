#!/bin/bash -xe

terraform init
terraform plan -out plan.out