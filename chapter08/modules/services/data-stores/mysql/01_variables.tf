variable "db_username" {
  description = "DB user name"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name to use for the database"
  type        = string
  default     = "terraformdb"
}

variable "env_type" {
  description = "Environment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "subnet3_cidr" {
  description = "Subnet3 CIDR Block"
  type        = string
}

variable "subnet4_cidr" {
  description = "Subnet4 CIDR Block"
  type        = string
}
