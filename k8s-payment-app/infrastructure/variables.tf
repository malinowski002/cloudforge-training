variable "db_password" {
    type = string
    sensitive = true
    description = "Password for the PostgreSQL instance on EC2"
}