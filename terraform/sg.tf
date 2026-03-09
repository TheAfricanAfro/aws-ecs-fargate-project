# alb Security Group
resource "aws_security_group" "project_alb_sg" {
  name        = "project-alb-sg"
  description = "Allows inbound HTTP traffic from internet"
  vpc_id      = aws_vpc.project_vpc.id

  tags = {
    Name = "project-alb-sg"
  }
}

# alb allows inbound port 80 traffic from internet
resource "aws_vpc_security_group_ingress_rule" "alb_http_ingress" {
  security_group_id = aws_security_group.project_alb_sg.id
  description       = "allow http traffic from internet"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# alb allows outbound all 
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.project_alb_sg.id
  description       = "Allow all traffic to outband. " #Come back to this later to allow ecs
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}



# ECS Security Group
resource "aws_security_group" "project_ecs_sg" {
  name        = "project-ecs-sg"
  description = "allows ibound alb traffic only + all outbound"
  vpc_id      = aws_vpc.project_vpc.id

  tags = {
    Name = "project-ecs-sg"
  }
}

# allow traffic from alb
resource "aws_vpc_security_group_ingress_rule" "ecs_ingress" {
  security_group_id            = aws_security_group.project_ecs_sg.id
  description                  = "Traffic from ALB only"
  from_port                    = 4000
  to_port                      = 4000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.project_alb_sg.id
}

# allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.project_ecs_sg.id
  description       = "allow to internet"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}