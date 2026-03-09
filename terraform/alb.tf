resource "aws_lb" "project_application_lb" {
  name               = "project-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project_alb_sg.id]
  subnets            = [aws_subnet.project_vpc_subnet_public_2a.id, aws_subnet.project_vpc_subnet_public_2b.id]
  enable_deletion_protection = false
  tags = {
    Name = "project-application-lb"
  }
}

resource "aws_lb_target_group" "project_tg" {
  name        = "project-tg"
  target_type = "ip"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.project_vpc.id
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port" #Best practice is to use this. Changed from 4000.
    protocol            = "HTTP"
    healthy_threshold   = 2 #Default is 3. 
    unhealthy_threshold = 3 #Default is 3.
    timeout             = 7
    interval            = 30
    matcher             = "200" #Terraform documen stats number can be any number 200-299. Using 200.
  }

  tags = {
    Name = "project-tg"
  }
}

resource "aws_lb_listener" "project_listener" {
  load_balancer_arn = aws_lb.project_application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_tg.arn
  }
}