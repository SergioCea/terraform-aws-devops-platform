resource "aws_ecs_cluster" "art_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-cluster" })
}

resource "aws_ecs_task_definition" "gitea" {
  family                   = "${var.environment}-gitea-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = aws_iam_role.ecs_task_gitea_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "gitea"
      image = "docker.gitea.com/gitea:1.26.2"
      cpu   = 2048
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
          name          = "gitea-3000-tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      environment = [
        { name = "GITEA__database__USER", value = aws_db_instance.gitea_db.username },
        { name = "APP_NAME", value = var.project_name },
        { name = "GITEA__server__HTTP_PORT", value = "3000" },
        { name = "USER_UID", value = "1000" },
        { name = "GITEA__server__PROTOCOL", value = "http" },
        { name = "GITEA__database__DB_TYPE", value = "postgres" },
        { name = "GITEA__openid__ENABLE_OPENID_SIGNIN", value = "false" },
        { name = "GITEA__database__NAME", value = aws_db_instance.gitea_db.db_name },
        { name = "USER_GID", value = "1000" },
        { name = "GITEA__database__HOST", value = aws_db_instance.gitea_db.endpoint },
        { name = "GITEA__server__DOMAIN", value = var.host_gitea },
        { name = "GITEA__server__ROOT_URL", value = var.dns_gitea },
        { name = "GITEA__server__DISABLE_SSH", value = "true" },
        { name = "GITEA__database__SSL_MODE", value = "require" }
      ]
      secrets = [
        {
          name      = "GITEA__database__PASSWD"
          valueFrom = aws_secretsmanager_secret.db_gitea_pw.arn
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "gitea_data"
          containerPath = "/data"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/gitea-task"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  volume {
    name                = "gitea_data"
    configure_at_launch = false

    s3files_volume_configuration {
      file_system_arn         = aws_s3files_file_system.s3_file_system.arn
      root_directory          = "/"
      transit_encryption_port = 2049
      access_point_arn        = aws_s3files_access_point.s3_files_system_ap.arn
    }
  }
}

resource "aws_ecs_task_definition" "keycloak" {
  family                   = "${var.environment}-keycloak-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role_keycloak.arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "keycloak"
      image = "quay.io/keycloak/keycloak:26.6.2"
      cpu   = 1024
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        },
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]
      essential = true
      environment = [
        { name = "KC_DB", value = "postgres" },
        { name = "KC_DB_URL", value = "jdbc:postgresql://${aws_db_instance.keycloak_db.endpoint}/${aws_db_instance.keycloak_db.db_name}" },
        { name = "KC_DB_USERNAME", value = aws_db_instance.keycloak_db.username },
        { name = "KC_HOSTNAME", value = var.dns_keycloak },
        { name = "KC_HTTP_ENABLED", value = "true" },
        { name = "KC_HOSTNAME_STRICT", value = "false" }
      ]
      secrets = [
        {
          name      = "KC_DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_keycloak_pw.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/keycloak-task"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "${var.environment}-sonarqube-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = aws_iam_role.ecs_task_sonarqube_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role_sonarqube.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name  = "sonarqube"
      image = "sonarqube:community"
      cpu   = 2048
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
          name          = "sonarqube-9000-tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      environment = [
        { name = "SONAR_JDBC_URL", value = "jdbc:postgresql://${aws_db_instance.sonarqube_db.endpoint}/${aws_db_instance.sonarqube_db.db_name}" },
        { name = "SONAR_JDBC_USERNAME", value = aws_db_instance.sonarqube_db.username }
      ]
      secrets = [
        {
          name      = "SONAR_JDBC_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_sonarqube_pw.arn
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "sonarqube_data"
          containerPath = "/opt/sonarqube/data"
          readOnly      = false
        },
        {
          sourceVolume  = "sonarqube_extensions"
          containerPath = "/opt/sonarqube/extensions"
          readOnly      = false
        },
        {
          sourceVolume  = "sonarqube_logs"
          containerPath = "/opt/sonarqube/logs"
          readOnly      = false
        }
      ]

      ulimits = [
        {
          name      = "nofile"
          hardLimit = 131072
          softLimit = 131072
        },
        {
          name      = "nproc"
          hardLimit = 8192
          softLimit = 8192
        },
      ]

      command = ["-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false"]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/sonarqube-task"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  volume {
    name                = "sonarqube_data"
    configure_at_launch = false

    s3files_volume_configuration {
      file_system_arn  = aws_s3files_file_system.s3_file_system.arn
      root_directory   = "/"
      access_point_arn = aws_s3files_access_point.s3_files_system_sonar_data.arn
    }
  }

  volume {
    name                = "sonarqube_extensions"
    configure_at_launch = false

    s3files_volume_configuration {
      file_system_arn  = aws_s3files_file_system.s3_file_system.arn
      root_directory   = "/"
      access_point_arn = aws_s3files_access_point.s3_files_system_sonar_extensions.arn
    }
  }

  volume {
    name                = "sonarqube_logs"
    configure_at_launch = false

    s3files_volume_configuration {
      file_system_arn  = aws_s3files_file_system.s3_file_system.arn
      root_directory   = "/"
      access_point_arn = aws_s3files_access_point.s3_files_system_sonar_logs.arn
    }
  }
}
