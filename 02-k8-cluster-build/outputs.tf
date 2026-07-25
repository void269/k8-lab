output "manager_public_ip" {
  description = "Public IP address of the Kubernetes control plane"
  value       = aws_instance.k8_manager.public_ip
}

output "manager_ssh_command" {
  description = "SSH command for connecting to the Kubernetes control plane"
  value       = "ssh -i \"${var.ssh_key_path}\" ${var.username}@${aws_instance.k8_manager.public_ip}"
}

output "worker_public_ips" {
  description = "Public IP addresses of the Kubernetes worker nodes"
  value       = aws_instance.k8_worker[*].public_ip
}

output "worker_ssh_commands" {
  description = "SSH commands for connecting to the Kubernetes worker nodes"
  value = [
    for worker in aws_instance.k8_worker :
    "ssh -i \"${var.ssh_key_path}\" ${var.username}@${worker.public_ip}"
  ]
}