variable "region" {
  description = "Specifies the region for resource creation"
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "cidr block for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami-id" {
  description = "AMI id for EC2 creation"
  type        = string
  default     = "ami-0440d3b780d96b29d"
}

variable "instance-type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}
