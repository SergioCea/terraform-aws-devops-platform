resource "aws_secretsmanager_secret" "db_gitea_pw" {
  name                    = "${var.project_name}-${var.environment}-gitea-db-password"
  description             = "Gitea database password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_gitea_pw" {
  secret_id                = aws_secretsmanager_secret.db_gitea_pw.id
  secret_string_wo         = random_password.gitea_db_pw.result
  secret_string_wo_version = 1
}

resource "aws_secretsmanager_secret" "db_keycloak_pw" {
  name                    = "${var.project_name}-${var.environment}-keycloak-db-password"
  description             = "Keycloak database password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_keycloak_pw" {
  secret_id                = aws_secretsmanager_secret.db_keycloak_pw.id
  secret_string_wo         = random_password.keycloak_db_pw.result
  secret_string_wo_version = 1
}

resource "aws_secretsmanager_secret" "db_sonarqube_pw" {
  name                    = "${var.project_name}-${var.environment}-sonarqube-db-password"
  description             = "SonarQube database password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_sonarqube_pw" {
  secret_id                = aws_secretsmanager_secret.db_sonarqube_pw.id
  secret_string_wo         = random_password.sonarqube_db_pw.result
  secret_string_wo_version = 1
}
