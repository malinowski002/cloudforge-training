output "private_ip" {
    value = aws_instance.postgres_vm.private_ip
}

output "instance_id" {
    value = aws_instance.postgres_vm.id
}

output "security_group_id" {
    value = aws_security_group.postgres_vm.id
}