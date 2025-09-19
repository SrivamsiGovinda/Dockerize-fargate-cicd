variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "myapp"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}