output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.windows_gpu.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.windows_gpu.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.windows_gpu.private_ip
}

output "dcv_connection" {
  description = "DCV connection URL"
  value       = "https://${aws_instance.windows_gpu.public_ip}:8443"
}

output "dcv_credentials" {
  description = "DCV login credentials"
  value       = "Username: Administrator | Password: WyObs2025!"
  sensitive   = true
}

output "instance_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.windows_gpu.public_dns
}
