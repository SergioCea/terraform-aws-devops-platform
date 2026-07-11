resource "aws_lb" "alb_art" {
  name               = "alb-${var.project_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-art.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = merge(local.common_tags, { Name = "alb-${var.project_name}-${var.environment}" })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_lb_target_group" "tg_gitea" {
  name                 = "tg-${var.environment}-gitea"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/api/healthz"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(local.common_tags, { Name = "tg-${var.environment}-gitea" })
}

resource "aws_lb_target_group" "tg_keycloak" {
  name                 = "tg-${var.environment}-keycloak"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/health/live"
    port                = "9000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(local.common_tags, { Name = "tg-${var.environment}-keycloak" })
}

resource "aws_lb_target_group" "tg_sonarqube" {
  name                 = "tg-${var.environment}-sonarqube"
  port                 = 9000
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/api/system/status"
    port                = "9000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(local.common_tags, { Name = "tg-${var.environment}-sonarqube" })
}

data "aws_acm_certificate" "art" {
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "listener_alb" {
  load_balancer_arn = aws_lb.alb_art.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.art.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_keycloak.arn
  }

  tags = merge(local.common_tags, { Name = "alb-listener" })
}

resource "aws_lb_listener_rule" "gitea_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_gitea.arn
  }

  condition {
    host_header {
      values = [var.host_gitea]
    }
  }
}

resource "aws_lb_listener_rule" "keycloak_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_keycloak.arn
  }

  condition {
    host_header {
      values = [var.host_keycloak]
    }
  }
}

resource "aws_lb_listener_rule" "sonarqube_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_sonarqube.arn
  }

  condition {
    host_header {
      values = [var.host_sonarqube]
    }
  }
}