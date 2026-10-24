output "web_public_ip" {
  description = "Public IP of the web server EC2 instance."
  value       = aws_eip.web.public_ip
}

output "db_private_ip" {
  description = "Private IP of the database EC2 instance."
  value       = aws_instance.db.private_ip
}

output "app_url" {
  value = "http://${aws_eip.web.public_ip}"
}

output "ssh_web" {
  value = "ssh -i ${var.private_key_path} ${var.ssh_user}@${aws_eip.web.public_ip}"
}

output "ssh_db_via_web" {
  value = "ssh -i ${var.private_key_path} -J ${var.ssh_user}@${aws_eip.web.public_ip} ${var.ssh_user}@${aws_instance.db.private_ip}"
}
