variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "eu-south-2"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "aws-art"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. prod, staging)"
  default     = "test"
  validation {
    condition     = contains(["prod", "test", "dev"], var.environment)
    error_message = "Environment must be one of: prod, test, dev."
  }
}

variable "zone_route53" {
  type        = string
  description = "Zone of Route53"
}

variable "certificate_domain" {
  type        = string
  description = "Name of the certificate domain"
}

variable "dns_gitea" {
  type        = string
  description = "DNS record for Gitea service"
}

variable "host_gitea" {
  type        = string
  description = "Host for Gitea service"
}

variable "dns_keycloak" {
  type        = string
  description = "DNS record for Keycloak service"
}

variable "host_keycloak" {
  type        = string
  description = "Host for Keycloak Service"
}

variable "host_sonarqube" {
  type        = string
  description = "Host for SonarQube Service"
}

