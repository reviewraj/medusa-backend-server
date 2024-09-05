# Auto Scaling Target for Medusa Backend Service
resource "aws_appautoscaling_target" "pearlthoughts_medusa_scaling_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster_to_deploy_the_containers.id}/${aws_ecs_service.pearlthoughts_medusa.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Medusa Backend Service
resource "aws_appautoscaling_policy" "pearlthoughts_medusa_cpu_scaling_policy" {
  name                   = "pearlthoughts-medusa-cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.pearlthoughts_medusa_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.pearlthoughts_medusa_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.pearlthoughts_medusa_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 60  # Cooldown period for scaling out
    scale_in_cooldown  = 60  # Cooldown period for scaling in
  }
}

