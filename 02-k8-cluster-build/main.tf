//Building the VPC and subnets for the Kubernetes cluster
resource "aws_vpc" "vpc01" {
  cidr_block = var.cidr_block

  tags = {
    Name = "AWS VPC for ${var.env}"
    ENV = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    Name = "VPC Internet Gateway"
    ENV = var.env
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id  = aws_vpc.vpc01.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.aws_az_list, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
    ENV = var.env
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id  = aws_vpc.vpc01.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone  = element(var.aws_az_list, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${count.index + 1}"
    ENV = var.env
  }
}

//Building the route table and associating it with the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
    ENV = var.env
  }
}

resource "aws_route_table_association" "aws-rt" {
  count = length(var.public_subnet_cidrs)
  subnet_id  = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

//Building the security group for the Kubernetes cluster EC2 instances
resource "aws_security_group" "net_traffic_sg" {
  name = "net_traffic_sg"
  description = "Allow inbound/outbound traffic"
  vpc_id = aws_vpc.vpc01.id

  ingress {
    description = "Allow internal communication"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    description = "SSH from anywhere"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow pub access to k8 API"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
/*
  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8 Cluster SG"
    ENV = var.env
  }
}


//Deploying the Kubernetes cluster EC2 instances
resource "aws_instance" "k8_control_plane" {
  ami = var.ami_image_id
  availability_zone = element(var.aws_az_list, 0)
  instance_type = var.ec2_instance_type_control_plane
  key_name = var.ssh_key
  vpc_security_group_ids = [aws_security_group.net_traffic_sg.id]
  subnet_id = aws_subnet.public[0].id
  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/control-plane.sh.tftpl",
    {
      kubernetes_version = var.k8_version
      pod_cidr = var.pod_cidr
    }
  )

  user_data_replace_on_change = true

  tags = {
    Name = "k8_control_plane"
    ENV = var.env
    Role = "control-plane"
  }
}

resource "aws_instance" "k8_worker" {
  ami = var.ami_image_id
  count = 2
  availability_zone = element(var.aws_az_list, 0)
  instance_type = var.ec2_instance_type_worker
  key_name = var.ssh_key
  vpc_security_group_ids = [aws_security_group.net_traffic_sg.id]
  subnet_id = aws_subnet.public[0].id
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/worker.sh.tftpl", {
    kubernetes_version = var.k8_version
    worker_name = "k8_worker-${count.index + 1}"
  })

  user_data_replace_on_change = true

  tags = {
    Name = "k8_worker"
    ENV = var.env
    Role = "worker"
  }

  depends_on = [aws_instance.k8_control_plane]
}

// Joining the worker nodes to the Kubernetes cluster
resource "terraform_data" "get_join_command" {
  depends_on = [
    aws_instance.k8_control_plane
  ]

  triggers_replace = [
    aws_instance.k8_control_plane.id,
    sha256(file("${path.module}/control-plane.sh.tftpl"))
  ]

  connection {
    type = "ssh"
    host = aws_instance.k8_control_plane.public_ip
    user = var.username
    private_key = file(pathexpand(var.ssh_key_path))
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/tmp/k8-control-plane-ready ]; do echo 'Waiting for Kubernetes control plane initialization...'; sleep 10; done",
      "test -s /home/ubuntu/join.sh"
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o ConnectTimeout=10 -i \"${var.ssh_key_path}\" \"ubuntu@${aws_instance.k8_control_plane.public_ip}:/home/ubuntu/join.sh\" \"${path.module}/join.sh\""
  }
}

resource "terraform_data" "join_workers" {
  count = length(aws_instance.k8_worker)

  depends_on = [
    terraform_data.get_join_command,
    aws_instance.k8_worker
  ]

  triggers_replace = [
    aws_instance.k8_worker[count.index].id,
    terraform_data.get_join_command.id
  ]

  connection {
    type = "ssh"
    host = aws_instance.k8_worker[count.index].public_ip
    user = var.username
    private_key = file(pathexpand(var.ssh_key_path))
    timeout = "15m"
  }

  provisioner "file" {
    source = "${path.module}/join.sh"
    destination = "/tmp/join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/tmp/k8-worker-ready ]; do echo 'Waiting for worker bootstrap...'; sleep 10; done",
      "chmod 700 /tmp/join.sh",
      "sudo /tmp/join.sh",
      "touch /var/tmp/k8-worker-joined"
    ]
  }
}