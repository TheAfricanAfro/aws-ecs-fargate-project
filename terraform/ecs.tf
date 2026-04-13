resource "aws_ecs_cluster" "project_cluster" {
  name = "project-cluster"

  tags = {
    Name = "project-cluster"
  }
}

resource "aws_ecs_task_definition" "project_task" {
  family                   = "project-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512  #.5CPU
  memory                   = 1024 # 1GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "project-container"
      image     = "${aws_ecr_repository.project_ecr_repo.repository_url}:latest"
      essential = true #Crashses if anything fails

      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "project-task"
  }
}



resource "aws_ecs_service" "project_service" {
  name            = "project-service"
  cluster         = aws_ecs_cluster.project_cluster.id
  task_definition = aws_ecs_task_definition.project_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.project_vpc_subnet_private_2a.id, aws_subnet.project_vpc_subnet_private_2b.id]
    security_groups  = [aws_security_group.project_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.project_tg.arn
    container_name   = "project-container"
    container_port   = 4000
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [aws_lb_listener.project_listener]

  tags = {
    Name = "project-service"
  }
}