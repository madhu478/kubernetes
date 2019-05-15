provider "aws" {
region = "us-east-2"
shared_credentials_file= "~/.aws/credentials"
profile = "phani"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
    tags = {
    Name = "myvpc"
         }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone= "us-east-2a"
  tags = {
    Name = "pubsub_1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone= "us-east-2b"
  tags = {
    Name = "pubsub_2"
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone= "us-east-2a"
  tags = {
    Name = "prisub_1"
  }
}
resource "aws_subnet" "subnet4" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone= "us-east-2b"
  tags = {
    Name = "prisub_2"
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "myigw"
  }
}
resource "aws_route_table" "mypubrt" {
  vpc_id = "${aws_vpc.myvpc.id}"
  
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myigw.id}"
  }

  tags = {
    Name= "mypubrt"
  }
}
resource "aws_route_table_association" "pussubass" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.mypubrt.id}"
}
resource "aws_route_table_association" "pussubass_1" { 
 subnet_id      = "${aws_subnet.subnet2.id}"                                                                                                                                               route_table_id = "${aws_route_table.mypubrt.id}"
}
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appserver" {
  name        = "appserver"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
ingress {
    # TLS (change to whatever ports you need)
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database" {
  name        = "database"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
ingress {
    # TLS (change to whatever ports you need)
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_eip" "nat" {
  vpc      = true
}
resource "aws_eip" "nat2" {
  vpc      = true
}


resource "aws_nat_gateway" "mynatgw1" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.subnet1.id}"

  tags = {
    Name = "myNATgw_1"
  }
}

resource "aws_nat_gateway" "mynatgw2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id     = "${aws_subnet.subnet2.id}"

  tags = {
    Name = "myNATgw_2"
  }
}
resource "aws_route_table" "myprirt" {
vpc_id ="${aws_vpc.myvpc.id}"
route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.mynatgw1.id}"
    }
 tags = {
 Name= "MypriRt"
 }
}
resource "aws_route_table_association" "prisubass" {
 subnet_id = "${aws_subnet.subnet3.id}"
 route_table_id = "${aws_route_table.myprirt.id}"
 }
resource "aws_route_table_association" "prisubass_1" { 
subnet_id = "${aws_subnet.subnet4.id}"                                                                                                                                                    route_table_id = "${aws_route_table.myprirt.id}"
}

 resource "aws_route" "r" {
   route_table_id = "${aws_route_table.myprirt.id}"
   destination_cidr_block = "::/0"
   nat_gateway_id = "${aws_nat_gateway.mynatgw2.id}"
   }
 
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
  vpc_zone_identifier       = ["${aws_subnet.subnet3.id}", "${aws_subnet.subnet4.id}"]

 }
resource "aws_autoscaling_policy" "upapp" {
  name                   = "up_appserver"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.AutoAPP.name}"
}
resource "aws_sns_topic" "appin"{
  name = "App_increase"
}
resource "aws_sns_topic" "appde" {
  name = "APP_decrease"
  }
resource "aws_autoscaling_notification" "Increase_APP" {
  group_names = ["${aws_autoscaling_group.AutoAPP.name}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
   ]
  topic_arn = "${aws_sns_topic.appin.arn}"
  }
resource "aws_autoscaling_notification" "Decrease_APP" {
  group_names = ["${aws_autoscaling_group.AutoAPP.name}"]
  notifications = [
  "autoscaling:EC2_INSTANCE_TERMINATE"
  ]
   topic_arn = "${aws_sns_topic.appde.arn}"
   }
