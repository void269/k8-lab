#!/bin/bash
POSTFIX=$(echo $RANDOM | md5sum | head -c 4)

echo "Creating EC2 instance"

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0b6d9d3d33ba97d99 \
    --count 1 \
    --instance-type t2.micro \
    --key-name Demo-key-01 \
    --security-group-ids sg-008d923276860130a \
    --subnet-id subnet-0e1df5de38781daec \
    --associate-public-ip-address \
    --user-data file://user-data-k8-install.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=K8s-Manager-$POSTFIX}]" \
    --region us-east-1 \
    --query "Instances[0].InstanceId" \
    --output text
    )

echo "Waiting for instance to be in 'running' state..."

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region us-east-1

echo "Instance is running! Fetching final output:"

# 4. Query the completed metadata
aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region us-east-1 \
    --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value | [0], PublicIpAddress]" \
    --output text
