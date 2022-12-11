variable "ex8_cluster_name" {
  description = "The name of cluster"
  type        = string
}

variable "db_remote_state_bucket_name" {
  description = "ex8 remote state bucket name"
  type        = string
}

variable "db_remote_state_key" {
  description = "ex8 remote state key path"
  type        = string
}

variable "env_type" {
  description = "Defines which type is provisioned"
  type        = string
}

####
# performance
####
variable "instance_type" {
  description = "Type of EC2 instances"
  type        = string
}

variable "min_size" {
  description = "minimum number of ec2 instances"
  type        = number
}

variable "max_size" {
  description = "maximim number of ec2 instances"
  type        = number
}
