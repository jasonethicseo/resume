resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-970728"
  tags = {
    Name = "ecs-cluster-970728"
  }
}

data "aws_ami" "ecs_optimized" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}



resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-launch-template-970728"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = "t2.large"
  key_name      = "KEYPAIR-2-UBUNTU"  # SSH Key Pair 이름

  block_device_mappings {
    device_name = "/dev/xvda"  // 인스턴스 타입과 AMI에 따라 적절히 조정

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }


  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  echo ECS_CLUSTER=ecs-cluster-970728 >> /etc/ecs/ecs.config

  # sudo yum update -y
  # sudo yum install -y ecs-init docker
  # sudo systemctl enable docker
  # sudo systemctl start docker
  # sudo systemctl enable ecs
  # sudo systemctl start ecs

  # # Docker plugin 설치
  # sudo docker plugin install --alias cloudstor:aws --grant-all-permissions docker4x/cloudstor:18.09.2-ce-aws1 CLOUD_PLATFORM=AWS AWS_REGION=us-east-1 EFS_SUPPORTED=0 DEBUG=1

  # # ECS 에이전트 재시작
  # echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
  # sudo systemctl restart ecs

  EOF
  )

  iam_instance_profile {
    name = data.aws_iam_instance_profile.ecs_instance_profile.name
  }
}


# ecs instance role에 codedeployfullaccess가 들어가있어야 함.

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsinstancerole"
}

# resource "aws_iam_instance_profile" "ecs_instance_profile" {
#   name = "ecsInstanceProfile"
#   role = data.aws_iam_role.ecs_instance_role.name
# }

# 이미 존재하는 역할을 데이터 소스로 가져옴
data "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
}


resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2  # 원하는 용량 설정
  min_size             = 2
  max_size             = 5
  vpc_zone_identifier  = [
    aws_subnet.prv_sub_1.id,
    aws_subnet.prv_sub_2.id
  ]
  target_group_arns    = [aws_lb_target_group.target_ecs_ec2.arn]  # 타겟 그룹 ARN 추가

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-ec2-instance"
    propagate_at_launch = true
  }

  # 인스턴스 보호 설정 추가
  protect_from_scale_in = true

}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg-970728"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-security-group"
  }
}



resource "aws_security_group" "ecs_ec2_sg" {
  name        = "ecs-ec2-sg-970728"  # 보안 그룹의 이름을 설정합니다.
  vpc_id      = aws_vpc.my_vpc.id  # 보안 그룹이 속할 VPC를 지정합니다.

  # 인바운드 규칙: 서버 포트와 퍼블릭 서브넷에서의 트래픽을 허용합니다.
  ingress {
    from_port   = var.server_port  # 허용할 포트 번호입니다.
    to_port     = var.server_port  # 허용할 포트 번호입니다.
    protocol    = "tcp"  # TCP 프로토콜을 사용합니다.
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # 인바운드 규칙: SSH(포트 22)를 모든 IP에서 허용합니다.
  ingress {
    from_port   = 22  # 포트 22를 허용합니다.
    to_port     = 22  # 포트 22를 허용합니다.
    protocol    = "tcp"  # TCP 프로토콜을 사용합니다.
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP에서의 트래픽을 허용합니다.
  }

  # 아웃바운드 규칙: 모든 트래픽을 허용합니다.
  egress {
    from_port   = 0  # 모든 포트를 허용합니다.
    to_port     = 0  # 모든 포트를 허용합니다.
    protocol    = "-1"  # 모든 프로토콜을 허용합니다.
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP로의 트래픽을 허용합니다.
  }
}


# Capacity Provider 생성
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "capacity-provider-970728"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.app_asg.arn
    managed_termination_protection = "ENABLED"
  }
}

# Capacity Provider를 ECS 클러스터에 연결
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs_capacity_provider.name,
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
    base              = 0
  }
}








# 애플리케이션 로드 밸런서의 보안 그룹을 생성합니다.
resource "aws_security_group" "alb_sg" {
    name = "sg-ecs-alb"  # 보안 그룹의 이름을 설정합니다.
    vpc_id = aws_vpc.my_vpc.id  # 보안 그룹이 속할 VPC를 지정합니다.

    # 인바운드 규칙: 서버 포트와 자신의 IP에서의 트래픽을 허용합니다.
    ingress {
        from_port = 8080  # 허용할 포트 번호입니다.
        to_port = 8080  # 허용할 포트 번호입니다.
        protocol = "tcp"  # TCP 프로토콜을 사용합니다.
        cidr_blocks = [var.my_ip]  # 특정 IP에서의 트래픽을 허용합니다.
    }

    # 아웃바운드 규칙: 모든 트래픽을 허용합니다.
    egress {
        from_port = 0  # 모든 포트를 허용합니다.
        to_port = 0  # 모든 포트를 허용합니다.
        protocol = "-1"  # 모든 프로토콜을 허용합니다.
        cidr_blocks = ["0.0.0.0/0"]  # 모든 IP로의 트래픽을 허용합니다.
    }
}

# 애플리케이션 로드 밸런서를 생성합니다.
resource "aws_lb" "ecs_ec2_alb" {
    name = "ecs-ec2-alb-970728"  # 로드 밸런서의 이름을 설정합니다.

    load_balancer_type = "application"  # 로드 밸런서의 타입을 애플리케이션으로 설정합니다.
    subnets = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]  # 로드 밸런서가 배치될 서브넷을 지정합니다.
    security_groups = [aws_security_group.ecs_ec2_sg.id]  # 로드 밸런서에 사용할 보안 그룹을 지정합니다.
}

# 애플리케이션 로드 밸런서의 타겟 그룹을 생성합니다.
resource "aws_lb_target_group" "target_ecs_ec2" {
    name = "TG-ec2-alb-970728"  # 타겟 그룹의 이름을 설정합니다.
    port = var.server_port  # 타겟 그룹이 수신할 포트를 설정합니다.
    protocol = "HTTP"  # HTTP 프로토콜을 사용합니다.
    vpc_id = aws_vpc.my_vpc.id  # 타겟 그룹이 속할 VPC를 지정합니다.

    # 헬스 체크 설정
    health_check {
        path = "/"  # 헬스 체크 경로를 설정합니다.
        protocol = "HTTP"  # HTTP 프로토콜을 사용합니다.
        matcher = "200,301,302"  # 헬스 체크 응답 코드로 200을 설정합니다.
        interval = 10  # 헬스 체크 간격을 10초로 설정합니다.
        timeout = 3  # 헬스 체크 타임아웃을 3초로 설정합니다.
        healthy_threshold = 2  # 헬시 상태를 결정하는 임계값을 2로 설정합니다.
        unhealthy_threshold = 2  # 언헬시 상태를 결정하는 임계값을 2로 설정합니다.
    }
}

# 애플리케이션 로드 밸런서의 리스너를 생성합니다.
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.ecs_ec2_alb.arn  # 리스너가 연결될 로드 밸런서의 ARN을 설정합니다.
    port = var.server_port  # 리스너가 수신할 포트를 설정합니다.
    protocol = "HTTP"  # HTTP 프로토콜을 사용합니다.

    # 기본 동작 설정: 요청을 타겟 그룹으로 포워딩합니다.
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_ecs_ec2.arn  # 포워딩할 타겟 그룹의 ARN을 설정합니다.
    }
}

# 애플리케이션 로드 밸런서의 리스너 규칙을 생성합니다.
resource "aws_lb_listener_rule" "ecs_ec2_asg_rule" {
    listener_arn = aws_lb_listener.http.arn  # 리스너의 ARN을 설정합니다.
    priority = 100  # 규칙의 우선순위를 설정합니다.
    condition {
        path_pattern {
            values = ["*"]  # 모든 경로 패턴에 대해 이 규칙을 적용합니다.
        }
    }
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_ecs_ec2.arn  # 요청을 포워딩할 타겟 그룹의 ARN을 설정합니다.
    }
}


resource "aws_lb" "ecs_alb_back" {
  name               = "ecs-alb-back-970728"
  internal           = false #cloudfront랑 연동시 internet-facing으로 설정
  load_balancer_type = "application"
  subnets            = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id] #cloudfront랑 연동시 internet-facing으로 설정
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "ECS ALB Back 970728"
  }
}

########################################################################awsvpc로 바꾼 후 리스너포트 8080으로 변경

resource "aws_lb_listener" "back_listener" {
  load_balancer_arn = aws_lb.ecs_alb_back.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ecs_back.arn
  }
}

resource "aws_lb_target_group" "tg_ecs_back" {
  name     = "TG-ECS-BACK-970728"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  ####awsvpc에서 얘 추가  
  target_type = "ip"

  health_check {
    path                = "/api/logout"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "TG-ECS-BACK-970728"
  }
}



resource "aws_ecs_service" "ecs_prjt_back_service" {
  name            = "ecs-prjt-back-service-970728"  # 백엔드 서비스 이름
  cluster         = aws_ecs_cluster.ecs_cluster.id  # 클러스터 ID
  task_definition = aws_ecs_task_definition.ecs_prjt_task_definition_back.arn  # 백엔드 태스크 정의 ARN
  desired_count   = 2  # 원하는 태스크 수
  launch_type     = "EC2"  # EC2로 실행

  deployment_controller {
    type = "CODE_DEPLOY"
  }

#####awsvpc에서 얘도 추가
  network_configuration {
    subnets         = [aws_subnet.prv_sub_1.id, aws_subnet.prv_sub_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_ecs_back.arn
    container_name   = "backend"
    container_port   = 8080
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  depends_on = [
    aws_lb_listener.back_listener
  ]

  tags = {
    Name = "ECS Backend Service 970728"
  }
}


resource "aws_lb_target_group" "tg_ecs_back_new" {
  name     = "TG-ECS-BACK-NEW-970728"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  
  ####awsvpc에서 얘 추가
  target_type = "ip"

  health_check {
    path                = "/api/logout"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "TG-ECS-BACK-NEW-970728"
  }
}


