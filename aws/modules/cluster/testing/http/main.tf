terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
  }
}

data "aws_lb" "lb" {
  arn = var.lb_arn
}

data "http" "lb" {
  depends_on = [data.aws_lb.lb]

  url                = "http://${data.aws_lb.lb.dns_name}"
  request_timeout_ms = 5000

  retry {
    attempts     = 20
    min_delay_ms = 10000
    max_delay_ms = 30000
  }
}

