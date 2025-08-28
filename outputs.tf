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

output "rdp_connection" {
  description = "RDP connection command"
  value       = "mstsc /v:${aws_instance.windows_gpu.public_ip}"
}

output "instance_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.windows_gpu.public_dns
}
