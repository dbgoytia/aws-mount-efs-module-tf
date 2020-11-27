variable "name" {
  description = "Name given for the NFS filesystem"
  type        = string
}

variable "subnets" {
  description = "Subnet for mounting the EFS volume. Preferably, an independent one."
  type        = string
}