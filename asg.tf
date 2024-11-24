resource "aws_autoscaling_group" "hw6_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 4
  desired_capacity = 1
  vpc_zone_identifier = [
    "subnet-0ddecd7cce1de8e55",
    "subnet-0bad8a1096921e468",
    "subnet-0202f5cebf5f3c58e",
    "subnet-0993e407ea571d980",
    "subnet-0c60d04012f245ab4",
    "subnet-033e7893eeb886211"
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_schedule" "scale_up" {
  depends_on = [aws_autoscaling_group.hw6_asg]
  scheduled_action_name  = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.hw6_asg.name
  desired_capacity       = 3
  start_time             = "2024-11-30T15:00:00Z"
}

resource "aws_autoscaling_schedule" "scale_down" {
  depends_on = [aws_autoscaling_group.hw6_asg]
  scheduled_action_name  = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.hw6_asg.name
  desired_capacity       = 1
  start_time             = "2024-11-30T18:00:00Z"
}