resource "aws_ecs_cluster" "project_cluster" {
  name = "project-cluster"

  #Interesting. Come back to this later.
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "project-cluster"
  }
}

resource "aws_ecs_task_definition" "project_task" {
  family                   = "project-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512  #.5CPU
  memory                   = 3072 # 3GB
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


  load_balancer {
    target_group_arn = aws_lb.project_application_lb.arn
    container_name   = "project-container"
    container_port   = 4000
  }

  depends_on = [aws_lb_listener.project_listener]

  tags = {
    Name = "project-service"
  }
}