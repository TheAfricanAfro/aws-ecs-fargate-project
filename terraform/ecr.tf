resource "aws_ecr_repository" "project_ecr_repo" {
  name                 = "production/project-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "production/project-repo"
  }
}