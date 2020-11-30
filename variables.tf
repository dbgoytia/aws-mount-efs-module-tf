variable "name" {
  description = "Name given for the NFS filesystem"
  type        = string
}

variable "subnets" {
  description = "Subnets for mounting the EFS volume."
  type        = string
}

variable "vpc_id" {
  type = string
  description = "The VPC ID where NFS security groups will be."
}