locals {
    tags_all = merge({Name = var.release_name, Environment = var.environment}, var.tags_all)

    containers = [ for container in var.container_definitions: {
        name                    = container.name
        image                   = container.image
        cpu                     = lookup(container, "cpu", null)
        memory                  = lookup(container, "memory", null)
        memoryReservation       = lookup(container, "memoryReservation", null)
        entrypoint              = lookup(container, "entrypoint", [])
        command                 = lookup(container, "command", [])
        privileged              = lookup(container, "privileged", false)
        user                    = lookup(container, "user", null)
        workingDirectory        = lookup(container, "workingDirectory", null)
        environment             = toset(concat(var.env_var_all, lookup(container, "environment", [])))
        environmentFiles        = toset(concat(var.env_var_files_all, lookup(container, "environmentFiles", [])))
        secrets                 = toset(concat(var.secrets_all, lookup(container, "secrets", [])))
        portMappings            = lookup(container, "portMappings", [])
        mountPoints             = lookup(container, "mountPoints", [])
        repositoryCredentials   = lookup(container, "repositoryCredentials", null)
        resourceRequirements    = lookup(container, "resourceRequirements", [])
        extraHosts              = lookup(container, "extraHosts", [])

        logConfiguration = var.cloudwatch_logs_enabled ? {
          logDriver = "awslogs"
          options = {
            "awslogs-create-group": "true",
            "awslogs-group": "/ecs/${var.environment}/${var.ecs_cluster_name}",
            "awslogs-region": data.aws_region.current.name,
            "awslogs-stream-prefix": var.release_name
          }
        } : null
    }]
}