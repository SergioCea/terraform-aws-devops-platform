resource "aws_ecs_service" "gitea_service" {
  name            = "${var.environment}-gitea-service"
  cluster         = aws_ecs_cluster.art_cluster.id
  task_definition = aws_ecs_task_definition.gitea.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    base              = 1
  }

  network_configuration {
    subnets          = [aws_subnet.private.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ecs-gitea.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_gitea.arn
    container_name   = "gitea"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.gitea_discovery.arn
  }

  depends_on = [aws_lb_listener.listener_alb]

  tags = merge(local.common_tags, { Name = "${var.environment}-gitea-service" })
}

resource "aws_ecs_service" "keycloak_service" {
  name            = "${var.environment}-keycloak-service"
  cluster         = aws_ecs_cluster.art_cluster.id
  task_definition = aws_ecs_task_definition.keycloak.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    base              = 1
  }

  network_configuration {
    subnets          = [aws_subnet.private.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ecs-keycloak.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_keycloak.arn
    container_name   = "keycloak"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.keycloak_discovery.arn
  }

  depends_on = [aws_lb_listener.listener_alb]

  tags = merge(local.common_tags, { Name = "${var.environment}-keycloak-service" })
}

resource "aws_ecs_service" "sonarqube_service" {
  name            = "${var.environment}-sonarqube-service"
  cluster         = aws_ecs_cluster.art_cluster.id
  task_definition = aws_ecs_task_definition.sonarqube.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    base              = 1
  }

  network_configuration {
    subnets          = [aws_subnet.private.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ecs-sonarqube.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_sonarqube.arn
    container_name   = "sonarqube"
    container_port   = 9000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sonarqube_discovery.arn
  }

  depends_on = [aws_lb_listener.listener_alb]

  tags = merge(local.common_tags, { Name = "${var.environment}-sonarqube-service" })
}
