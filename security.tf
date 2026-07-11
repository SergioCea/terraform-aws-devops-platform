resource "aws_security_group" "alb-art" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-alb-sg" })
}

resource "aws_security_group_rule" "alb-art_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Permite el acceso al ALB"
  security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group_rule" "alb-art_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico"
  security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group" "rds-gitea" {
  name        = "${var.project_name}-${var.environment}-rds-gitea-sg"
  description = "Security group for RDS Gitea"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-rds-gitea-sg" })
}

resource "aws_security_group_rule" "rds-gitea_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Permite el acceso a la base de datos"
  security_group_id        = aws_security_group.rds-gitea.id
  source_security_group_id = aws_security_group.ecs-gitea.id
}

resource "aws_security_group_rule" "rds-gitea_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para RDS"
  security_group_id = aws_security_group.rds-gitea.id
}

resource "aws_security_group" "ecs-gitea" {
  name        = "${var.project_name}-${var.environment}-ecs-gitea-sg"
  description = "Security group for ECS Gitea"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-ecs-gitea-sg" })
}

resource "aws_security_group_rule" "ecs-gitea_ingress" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  description              = "Permite el acceso desde el ALB"
  security_group_id        = aws_security_group.ecs-gitea.id
  source_security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group_rule" "ecs_sonarqube_ingress" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  description              = "Permite el acceso desde SonarQube"
  security_group_id        = aws_security_group.ecs-gitea.id
  source_security_group_id = aws_security_group.ecs-sonarqube.id
}

resource "aws_security_group_rule" "ecs_keycloak_ingress" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  description              = "Permite el acceso desde Keycloak"
  security_group_id        = aws_security_group.ecs-gitea.id
  source_security_group_id = aws_security_group.ecs-keycloak.id
}

resource "aws_security_group_rule" "ecs-gitea_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para ECS"
  security_group_id = aws_security_group.ecs-gitea.id
}

resource "aws_security_group_rule" "ecs-gitea_egress_fs" {
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs-gitea.id
  to_port                  = 2049
  type                     = "egress"
  source_security_group_id = aws_security_group.s3-fs.id
}


resource "aws_security_group" "ecs-sonarqube" {
  name        = "${var.project_name}-${var.environment}-ecs-sonarqube-sg"
  description = "Security group for ECS SonarQube"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-ecs-sonarqube-sg" })
}

resource "aws_security_group_rule" "ecs-sonarqube_ingress" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  description              = "Permite el acceso desde el ALB"
  security_group_id        = aws_security_group.ecs-sonarqube.id
  source_security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group_rule" "ecs-sonarqube_gitea_ingress" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  description              = "Permite el acceso desde Gitea "
  security_group_id        = aws_security_group.ecs-sonarqube.id
  source_security_group_id = aws_security_group.ecs-gitea.id
}

resource "aws_security_group_rule" "ecs-sonarqube_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para ECS"
  security_group_id = aws_security_group.ecs-sonarqube.id
}

resource "aws_security_group_rule" "ecs-sonarqube_egress_fs" {
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs-sonarqube.id
  to_port                  = 2049
  type                     = "egress"
  source_security_group_id = aws_security_group.s3-fs.id
}

resource "aws_security_group" "s3-fs" {
  name        = "${var.project_name}-${var.environment}-s3-fs-sg"
  description = "Security group for S3 Files"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-s3-fs-sg" })
}

resource "aws_security_group_rule" "s3-sf-gitea-ingress" {
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.s3-fs.id
  to_port                  = 2049
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs-gitea.id
}

resource "aws_security_group_rule" "s3-sf-sonarqube-ingress" {
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.s3-fs.id
  to_port                  = 2049
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs-sonarqube.id
}

resource "aws_security_group_rule" "s3-sf-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para ECS"
  security_group_id = aws_security_group.s3-fs.id
}

resource "aws_security_group" "ecs-keycloak" {
  name        = "${var.project_name}-${var.environment}-ecs-keycloak-sg"
  description = "Security group for ECS Keycloak"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-ecs-keycloak-sg" })
}

resource "aws_security_group_rule" "ecs-keycloak_ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  description              = "Permite el acceso desde el ALB"
  security_group_id        = aws_security_group.ecs-keycloak.id
  source_security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group_rule" "ecs_keycloak_ingress_health" {
  from_port                = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs-keycloak.id
  to_port                  = 9000
  type                     = "ingress"
  source_security_group_id = aws_security_group.alb-art.id
}

resource "aws_security_group_rule" "ecs_keycloak_ingress_gitea" {
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs-keycloak.id
  to_port                  = 8080
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs-gitea.id
}

resource "aws_security_group_rule" "ecs_keycloak_ingress_sonarqube" {
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs-keycloak.id
  to_port                  = 8080
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs-sonarqube.id
}

resource "aws_security_group_rule" "ecs-keycloak_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para ECS"
  security_group_id = aws_security_group.ecs-keycloak.id
}

resource "aws_security_group" "rds-keycloak" {
  name        = "${var.project_name}-${var.environment}-rds-keycloak-sg"
  description = "Security group for RDS Keycloak"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-rds-keycloak-sg" })
}

resource "aws_security_group_rule" "rds-keycloak_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Permite el acceso a la base de datos"
  security_group_id        = aws_security_group.rds-keycloak.id
  source_security_group_id = aws_security_group.ecs-keycloak.id
}

resource "aws_security_group_rule" "rds-keycloak_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para RDS"
  security_group_id = aws_security_group.rds-keycloak.id
}

resource "aws_security_group" "rds-sonarqube" {
  name        = "${var.project_name}-${var.environment}-rds-sonarqube-sg"
  description = "Security group for RDS SonarQube"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-rds-sonarqube-sg" })
}

resource "aws_security_group_rule" "rds-sonarqube_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Permite el acceso a la base de datos"
  security_group_id        = aws_security_group.rds-sonarqube.id
  source_security_group_id = aws_security_group.ecs-sonarqube.id
}

resource "aws_security_group_rule" "rds-sonarqube_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Salida total de trafico para RDS"
  security_group_id = aws_security_group.rds-sonarqube.id
}