aws ec2 run-instances \
    --image-id ami-0b6d9d3d33ba97d99 \
    --count 1 \
    --instance-type t2.micro \
    --key-name Demo-key-01 \
    --security-group-ids sg-008d923276860130a \
    --subnet-id subnet-0e1df5de38781daec \
    --user-data file://user-data-k8-install.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=K8s-Manager}]' \
    --region us-east-1