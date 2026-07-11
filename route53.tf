data "aws_route53_zone" "myzone" {
  name         = var.zone_route53
  private_zone = false
}

resource "aws_route53_record" "gitea" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = var.host_gitea
  type    = "A"

  alias {
    name                   = aws_lb.alb_art.dns_name
    zone_id                = aws_lb.alb_art.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "keycloak" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = var.host_keycloak
  type    = "A"

  alias {
    name                   = aws_lb.alb_art.dns_name
    zone_id                = aws_lb.alb_art.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "sonarqube" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = var.host_sonarqube
  type    = "A"

  alias {
    name                   = aws_lb.alb_art.dns_name
    zone_id                = aws_lb.alb_art.zone_id
    evaluate_target_health = true
  }
}
