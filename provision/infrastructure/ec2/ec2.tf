module "ec2_dev_app_frontend" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.6.0"
  name                        = "vytran-dev-app-frontend"
  instance_count              = 1
  instance_type               = "t2.micro"
  key_name                    = "ttt_dev"
  associate_public_ip_address = true
  disable_api_termination     = true
  cpu_credits                 = "standard"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "10"
    delete_on_termination = true
  }]

  ami                    = "ami-08a7da54f3bfb30e2"
  vpc_security_group_ids = ["sg-0e2782c205e9d8866"]
  subnet_id              = "subnet-8b10cced"

  tags       = {
    Stack = "app"
    Role = "frontend"
    Environment = "dev"
  }
  volume_tags = {
    Name        = "vytran-dev-app-frontend-root-volume" 
    Stack       = "app"
    Role        = "frontend"
    Environment = "dev"
  }
}




resource "aws_lb_target_group" "ec2_dev_app_frontend" {
  name     = "tg-dev-app-frontend"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "vpc-bd917adb"
  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
  stickiness {
    type = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_target_group_attachment" "ec2_dev_app_frontend" {
  count            = 1
  target_group_arn = aws_lb_target_group.ec2_dev_app_frontend.arn
  target_id        = element(module.ec2_dev_app_frontend.id, count.index)
  port             = 80
}



resource "aws_lb_listener_rule" "ec2_dev_app_frontend" {
  listener_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:790472559564:listener/app/vytran-alb-app/96f1cd0398feddac/a3027eb010c27941"
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ec2_dev_app_frontend.arn}"
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.ec2_dev_app_frontend.name]
  }

  condition {
    source_ip {
      // DevOps Ip,
      values = ["116.110.40.234/32"]
    }
  }
}

resource "aws_route53_record" "ec2_dev_app_frontend" {
  zone_id = "Z01260471YO2K5UHC24L4"
  name    = "app.vytran.tk"
  type    = "A"
  alias {
    name                   = "vytran-alb-app-28658519.ap-southeast-1.elb.amazonaws.com"
    zone_id                = "Z1LMS91P8CMLE5"
    evaluate_target_health = false
  }
}

