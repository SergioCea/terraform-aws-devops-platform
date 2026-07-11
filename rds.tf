resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]

  tags = merge(local.common_tags, { Name = "RDS Subnet Group" })
}

resource "aws_db_instance" "gitea_db" {
  identifier          = "${var.project_name}-${var.environment}-gitea-db"
  engine              = "postgres"
  engine_version      = "18.3"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  db_name             = "gitea"
  username            = "gitea"
  password_wo         = random_password.gitea_db_pw.result
  password_wo_version = 1
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds-gitea.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = merge(local.common_tags, { Name = "Gitea DB" })
}

resource "aws_db_instance" "keycloak_db" {
  identifier          = "${var.project_name}-${var.environment}-keycloak-db"
  engine              = "postgres"
  engine_version      = "18.3"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  db_name             = "keycloak"
  username            = "keycloak"
  password_wo         = random_password.keycloak_db_pw.result
  password_wo_version = 1
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds-keycloak.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = merge(local.common_tags, { Name = "Keycloak DB" })
}

resource "aws_db_instance" "sonarqube_db" {
  identifier          = "${var.project_name}-${var.environment}-sonarqube-db"
  engine              = "postgres"
  engine_version      = "18.3"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  db_name             = "sonar"
  username            = "sonar"
  password_wo         = random_password.sonarqube_db_pw.result
  password_wo_version = 1
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds-sonarqube.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = merge(local.common_tags, { Name = "SonarQube DB" })
}