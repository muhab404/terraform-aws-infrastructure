output "instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_instance.bastion.public_ip
}