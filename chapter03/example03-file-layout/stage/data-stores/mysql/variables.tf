variable "db_username" {
  description = "User name for my database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for my database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "A name of the database"
  type        = string
  default     = "tstudydb"
}
