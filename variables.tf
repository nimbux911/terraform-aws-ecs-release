# global inputs 
variable "release_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "env_var_all" {
    type = list(object({
        name    = string
        value   = string
    }))
    default = []
}

variable "env_var_files_all" {
    type = list(string)
    default = []
}

variable "secrets_all" {
    type = list(object({
        name       = string
        valueFrom  = string
    }))
    default = []
}

variable "tags_all" {
    type    = map
    default = {}
}

# service inputs 
variable "ecs_cluster_name" {
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
    default = null
}

variable "wait_deploy" {
    type    = bool
    default = false
}

variable "deployment_minimum_percent" {
    type    = number
    default = 100
}

variable "deployment_maximum_percent" {
    type    = number
    default = 200
}

variable "rollback_enabled" {
    type    = bool
    default = true
}

variable "capacity_provider" {
    type    = string
    default = null
}

variable "placement_constraints" {
    type    = list(object({
        type        = string
        expression  = string
    }))
    default = []
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

variable "tags_service" {
    type    = map
    default = {}
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

variable "elb_health_check_grace_period_seconds" {
    type    = number
    default = 60
}

# task definition inputs

variable "task_cpu" {
    type    = number
    default = 256
}

variable "task_memory" {
    type    = number
    default = 512
}

variable "task_execution_role_arn" {
    type = string
}

variable "task_role_arn" {
    type = string
}

variable "requires_compatibilities" {
    type    = list(string)
    default = ["FARGATE"]
}

variable "fargate_ephemeral_storage" {
    type    = number
    default = null
}

variable "tags_task" {
    type    = map
    default = {}
}

variable "container_definitions" {
    type = list
    default = null
}

variable "task_network_mode" {
    type    = string
    default = "awsvpc"
}

variable "host_volumes" {
    type    = list
    default = []
}

variable "docker_volumes" {
    type    = list
    default = []
}

variable "efs_volumes" {
    type    = list
    default = []
}

variable "cloudwatch_logs_enabled" {
    type    = bool
    default = true
}