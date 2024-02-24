variable "task_family" {
  type = string
}

variable "container_name" {
    type = string
}

variable "target_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "alb_health_check_path" {
  type = string
}

variable "service_security_group_ids" {
    type = list(string)
}

variable "service_subnet_list" {
    type = list(string)
}
