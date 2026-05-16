variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "prefix" {
  type = string
}

variable "scale_in" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_out" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}
