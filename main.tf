
resource "aws_ecs_task_definition" "main" {
  family                    = var.release_name
  cpu                       = 256
  memory                    = 512
  execution_role_arn        = ""
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE", "EC2"]
  task_role_arn             = ""

  volume {
    name      = "local-volume"
    host_path = "/path/to/volume"
  }

  volume {
    name      = "docker_volume"
    docker_volume_configuration {
      autoprovision = bool
      scope         = "shared/task"
    }
  }

  volume {
    name      = "efs_volume"
    efs_volume_configuration {
      file_system_id          = ""
      root_directory          = "/"
      transit_encryption      = "ENABLED/DISABLED"
      transit_encryption_port = 0
      authorization_config {
        access_point_id = ""
        iam             = "ENABLED/DISABLED "
      }
    }
  }

  ephemeral_storage {
    size_in_gib = 21 - 200
  }

  runtime_platform  {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions     = jsonencode([
    {
      name              = "ovio-api"
      image             = "nginx"
      cpu               = 0
      memory            = 0
      memoryReservation = 0
      entrypoint        = [""]
      command           = [""]
      privileged        = false
      user              = ""
      workingDirectory  = ""

      environment = [{
        name  = ""
        value = ""
      }]

      secrets = [{
        name      = ""
        valueFrom = ""
      }]

      portMappings = [
        {
          name          = "http"
          appProtocol   = "http"
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]

      mountPoints = [{
        containerPath = ""
        readOnly      = false
        sourceVolume  = ""
      }]

      repositoryCredentials = {
        credentialsParameter = ""
      }

      resourceRequirements = {
        type  = "GPU"
        value = "" 
      }

      extraHosts  = [{
        hostname  = ""
        ipAddress = ""
      }]

      logConfiguration {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = true
          awslogs-group         = "/ecs/env/cluster"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "service"
        }
      }


    }
  ])

  tags = var.tags

}

resource "aws_ecs_service" "main" {
  name                                = var.release_name
  cluster                             = var.ecs_cluster
  platform_version                    = "LATEST"
  propagate_tags                      = "TASK_DEFINITION"
  scheduling_strategy                 = var.scheduling_strategy
  desired_count                       = var.replica_count
  force_new_deployment                = true # it allows to get a newer docker image with the same tag. For instances :latest
  health_check_grace_period_seconds   = var.elb_enabled ? var.lb_health_check_grace_period_seconds : null
  launch_type                         = var.launch_type

  task_definition                     = aws_ecs_task_definition.main.arn
  wait_for_steady_state               = true

  deployment_minimum_healthy_percent  = var.deployment_minimum_percent
  deployment_maximum_percent          = var.deployment_maximum_percent


  dynamic "load_balancer" {
    for_each =  var.elb_enabled ? ["do it"] : []
    content {
      {
        elb_name            = var.classic_elb_name
        target_group_arn    = var.target_group_arn
        container_name      = var.elb_container_name
        container_port      = var.elb_container_port
      }
    }
  }

  network_configuration   {
    subnets             = var.subnets
    security_groups     = var.security_groups
    assign_public_ip    = var.assign_public_ip
  }

  capacity_provider_strategy  {
    base                = var.replica_count
    capacity_provider   = var.capacity_provider
    weight              = "100%"
  }

  deployment_circuit_breaker  {
    enable      = var.rollback_enabled
    rollback    = var.rollback_enabled
  }

  deployment_controller   {
    type    = "ECS"
  }

  tags = var.tags
}
