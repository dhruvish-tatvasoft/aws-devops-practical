output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.NodeAppServer.public_ip
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.NodeAppServer.id
}
