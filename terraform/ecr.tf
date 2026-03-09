resource "aws_ecr_repository" "project_ecr_repo" {
  name                 = "archiveaaaada/devops-project2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "archiveaaaada/devops-project2"
  }
}