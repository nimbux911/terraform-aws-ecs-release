
resource "aws_ecs_task_definition" "main" {
  family                    = var.release_name
  cpu                       = var.task_cpu
  memory                    = var.task_memory
  execution_role_arn        = var.task_execution_role_arn
  network_mode              = var.task_network_mode
  requires_compatibilities  = var.requires_compatibilities
  task_role_arn             = var.task_role_arn
  container_definitions     = jsonencode(local.containers)
  tags                      = merge(local.tags_all, var.tags_task)

  dynamic "volume" {
    for_each = var.host_volumes
    content {
      name      = each.value.name
      host_path = lookup(each.value, "host_path", null)
    }
  }

  dynamic "volume" {
    for_each = var.docker_volumes
    content {
      name      = each.key
      host_path = lookup(each.value, "host_path", null)
      docker_volume_configuration {
        autoprovision = lookup(each.value, "autoprovision", true)
        driver_opts   = lookup(each.value, "driver_opts", null)
        driver        = lookup(each.value, "driver", null)
        scope         = lookup(each.value, "scope", "shared")
      }
    }
  }

  dynamic "volume" {
    for_each = var.efs_volumes
    content {
      name      = each.key
      host_path = lookup(each.value, "host_path", null)
      efs_volume_configuration {
        file_system_id          = each.value.file_system_id
        root_directory          = lookup(each.value, "root_directory", null)
        transit_encryption      = lookup(each.value, "transit_encryption", "DISABLED")
        transit_encryption_port = lookup(each.value, "transit_encryption_port", null)
        authorization_config  {
          access_point_id = lookup(each.value.authorization_config, "access_point_id", null)
          iam             = lookup(each.value.authorization_config, "iam", "DISABLED")
        }
      }
    }
  }

  dynamic "ephemeral_storage" {
    for_each =  var.fargate_ephemeral_storage != null ? ["do it"] : []
    content {
      size_in_gib = var.fargate_ephemeral_storage
    }
  }

  runtime_platform  {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "main" {
  name                                = var.release_name
  cluster                             = data.aws_ecs_cluster.main.arn
  platform_version                    = "LATEST"
  propagate_tags                      = "TASK_DEFINITION"
  scheduling_strategy                 = var.scheduling_strategy
  desired_count                       = var.replica_count
  force_new_deployment                = true # it allows to get a newer docker image with the same tag. For instances :latest
  health_check_grace_period_seconds   = var.elb_enabled ? var.elb_health_check_grace_period_seconds : null
  launch_type                         = var.launch_type

  task_definition                     = aws_ecs_task_definition.main.arn
  wait_for_steady_state               = var.wait_deploy

  deployment_minimum_healthy_percent  = var.deployment_minimum_percent
  deployment_maximum_percent          = var.deployment_maximum_percent


  dynamic "load_balancer" {
    for_each =  var.elb_enabled ? ["do it"] : []
    content {
      elb_name          = var.classic_elb_name
      target_group_arn  = var.target_group_arn
      container_name    = var.elb_container_name
      container_port    = var.elb_container_port
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type        = each.type
      expression  = each.expression
    }
  }

  network_configuration {
    subnets             = var.subnets
    security_groups     = var.security_groups
    assign_public_ip    = var.assign_public_ip
  }


  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider != null ? ["do-it"] : []
    content {
      base                = var.replica_count
      capacity_provider   = var.capacity_provider
      weight              = 100
    }
  }

  deployment_circuit_breaker  {
    enable      = var.rollback_enabled
    rollback    = var.rollback_enabled
  }

  deployment_controller   {
    type    = "ECS"
  }

  tags = merge(local.tags_all, var.tags_service)
}
