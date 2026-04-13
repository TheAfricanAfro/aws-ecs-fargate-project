resource "aws_appautoscaling_target" "project_service" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.project_cluster.name}/${aws_ecs_service.project_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "cpu_usage_target_tracking" {
  name               = "project-service-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.project_service.resource_id
  scalable_dimension = aws_appautoscaling_target.project_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.project_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"

    }

    target_value = 70

  }
}