resource "aws_launch_configuration" "app_conf" {
  name          = "app_config"
  image_id      = "ami-02009e5309aa28468"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "AutoAPP" {
 max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.app_conf.name}"
  vpc_zone_identifier       = ["${aws_subnet.subnet3.id}",${aws_subnet.subnet4.id}"]
 }
resource "aws_autoscaling_policy" "upapp" {
  name                   = "up_appserver"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.AutoAPP.name}"
}
