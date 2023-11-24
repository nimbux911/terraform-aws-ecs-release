# service inputs 
variable "release_name" {
    type = string
}

variable "ecs_cluster" {
    type = string
}

variable "scheduling_strategy" {
    type    = string
    default = "REPLICA"
}

variable "replica_count" {
    type    = number
    default = 1
}

variable "launch_type" {
    type    = string
    default = "FARGATE"
}

variable "deployment_minimum_percent" {
    type    = string
    default = "100%"
}

variable "deployment_maximum_percent" {
    type    = string
    default = "200%"
}

variable "rollback_enabled" {
    type    = bool
    default = true
}

variable "capacity_provider" {
    type    = string
    default = "FARGATE"
}

variable "subnets" {
    type = list(string)
}

variable "assign_public_ip" {
    type    = bool
    default = false
}

variable "security_groups" {
    type    = list(string)
    default = []
}

# elb inputs
variable "elb_enabled" {
    type    = bool
    default = false
}

variable "classic_elb_name" {
    type    = string
    default = null
}

variable "target_group_arn" {
    type    = string
    default = null
}

variable "elb_container_name" {
    type    = string
    default = null
}

variable "elb_container_port" {
    type    = number
    default = null
}

variable "lb_health_check_grace_period_seconds" {
    type    = number
    default = 60
}
