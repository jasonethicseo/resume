#sg 및 ec2 생성

resource "aws_security_group" "gitlab_sg" {
  name        = "gitlab-sg"
  description = "Allow HTTP traffic on port 80"
  vpc_id      = aws_vpc.gitlab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# data "aws_ami" "latest_ubuntu" {
#   owners = ["099720109477"]  # Ubuntu AMI의 AWS 계정 ID
#   most_recent = true

#   filter {
#     name = "name"
#      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  # 최신 패턴
#   }
# }

############# 새로 gitlab 설치 시

# resource "aws_instance" "gitlab" {
#   ami           = data.aws_ami.latest_ubuntu.id
#   instance_type = "t2.large"
#   subnet_id     = aws_subnet.prv_sub_1.id
#   key_name       = "KEYPAIR-2-UBUNTU"

#   root_block_device {
#     volume_size           = 100   # 루트 EBS 볼륨의 크기 (GB)
#     volume_type           = "gp3" # 볼륨 유형
#     delete_on_termination = true  # 인스턴스 종료 시 볼륨 삭제 여부
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     # Update the package index and install required packages
#     sudo apt-get update -y
#     sudo apt-get install -y ca-certificates curl

#     # Add Docker's official GPG key and repository
#     sudo mkdir -m 0755 -p /etc/apt/keyrings
#     sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
#     sudo chmod a+r /etc/apt/keyrings/docker.asc
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#     sudo apt-get update

#     # Install Docker and Docker Compose
#     sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin doker-compose-plugin

#     # Install Docker Compose binary
#     sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
#     sudo chmod +x /usr/local/bin/docker-compose

#     # Create symbolic link for docker-compose
#     sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#     # Verify Docker Compose installation
#     docker-compose --version

#     # Setup GitLab
#     sudo mkdir -p /data/gitlab
#     sudo mkdir -p /data/gitlab/data /data/gitlab/logs /data/gitlab/config
#     sudo chown -R \$USER:\$USER /data/gitlab
#     sudo chmod -R 755 /data/gitlab

#     sudo curl -o /data/gitlab/docker-compose.yml https://970728-docker-compose-gitlab.s3.ca-central-1.amazonaws.com/gitlab_config/docker-compose.yml

#     sudo sed -i "s|external_url 'https://.*'|external_url 'https://${var.domain_name}'|g" /data/gitlab/docker-compose.yml

#     # Start GitLab container
#     sudo docker-compose -f /data/gitlab/docker-compose.yml up -d

#     while [ "$(sudo docker inspect -f '{{.State.Health.Status}}' gitlab)" != "healthy" ]; do
#       echo "Waiting for GitLab container to be healthy..."
#       sleep 10
#     done

#     # Update GitLab configuration inside the container
#     sudo docker exec gitlab /bin/bash -c "sed -i '/^# external_url/d' /etc/gitlab/gitlab.rb"
#     sudo docker exec gitlab /bin/bash -c "echo \"external_url 'https://${var.domain_name}'\" >> /etc/gitlab/gitlab.rb"
#     sudo docker exec gitlab /bin/bash -c "gitlab-ctl reconfigure"

#     # Setup GitLab Runner
#     sudo mkdir -p /data/gitlab-runner/config
#     sudo chown -R \$USER:\$USER /data/gitlab-runner

#     sudo curl -o /data/gitlab-runner/docker-compose.yml https://970728-docker-compose-gitlab.s3.ca-central-1.amazonaws.com/gitlab-runner_config/docker-compose.yml

#     # Start GitLab Runner container
#     sudo docker-compose -f /data/gitlab-runner/docker-compose.yml up -d
#   EOF



#   tags = {
#     Name = "ec2-gitlab-970728"
#   }

#   vpc_security_group_ids = [aws_security_group.gitlab_sg.id]
# }

############## 저장된 ami 이용시

resource "aws_instance" "gitlab" {
  ami           = "ami-06192c7f492990cdc"
  instance_type = "t2.large"
  subnet_id     = aws_subnet.prv_sub_1.id
  key_name       = "KEYPAIR-2-UBUNTU"

  root_block_device {
    volume_size           = 100   # 루트 EBS 볼륨의 크기 (GB)
    volume_type           = "gp3" # 볼륨 유형
    delete_on_termination = true  # 인스턴스 종료 시 볼륨 삭제 여부
  }


  tags = {
    Name = "ec2-gitlab-970728"
  }

  vpc_security_group_ids = [aws_security_group.gitlab_sg.id]
}

###############

resource "aws_security_group" "openvpn_sg" {
  name        = "openvpn-sg"
  description = "Allow traffic for OpenVPN and management interfaces"
  vpc_id      = aws_vpc.gitlab_vpc.id


  # Allow SSH (TCP 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN (UDP 1194)
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Admin (TCP 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Web Interface (TCP 943)
  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Additional Port (TCP 945)
  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow OpenVPN Alternative Port (UDP 1193)
  ingress {
    from_port   = 1193
    to_port     = 1193
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openvpn-sg"
  }
}

resource "aws_eip" "openvpn_eip" {
  instance = aws_instance.openvpn.id
}

resource "aws_instance" "openvpn" {
  ami           = "ami-0a14a0a5716389b2d" #openvpn ami id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.pub_sub_1.id
  key_name       = "KEYPAIR-2-UBUNTU"

  root_block_device {
    volume_size           = 30   # 루트 EBS 볼륨의 크기 (GB)
    volume_type           = "gp3" # 볼륨 유형
    delete_on_termination = true  # 인스턴스 종료 시 볼륨 삭제 여부
  }

  tags = {
    Name = "ec2-openvpn-970728"
  }

  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]
}


resource "aws_eip_association" "openvpn_eip_asso" {
  instance_id   = aws_instance.openvpn.id
  allocation_id  = aws_eip.openvpn_eip.id
}

#######################


# ACM 인증서 생성
resource "aws_acm_certificate" "example" {
    domain_name       = var.domain_name
    validation_method = "DNS"

    tags = {
        Name = "example-certificate"
    }
}


# 로컬 값을 사용하여 domain_validation_options를 list로 변환
locals {
  domain_validation_options_list = [
    for option in aws_acm_certificate.example.domain_validation_options : option
  ]
}

# DNS 검증을 위한 Route 53 레코드 생성
resource "aws_route53_record" "example_cert_validation" {
  count   = length(local.domain_validation_options_list)
  zone_id = var.route53_zone_id
  name    = local.domain_validation_options_list[count.index].resource_record_name
  type    = local.domain_validation_options_list[count.index].resource_record_type
  ttl     = 60
  records = [local.domain_validation_options_list[count.index].resource_record_value]

  depends_on = [aws_acm_certificate.example]
}


# ACM 인증서 검증 완료
resource "aws_acm_certificate_validation" "example" {
    certificate_arn = aws_acm_certificate.example.arn

    validation_record_fqdns = [
        for record in aws_route53_record.example_cert_validation : record.fqdn
    ]
    
    depends_on = [aws_route53_record.example_cert_validation]  # 검증 레코드가 생성된 후 인증서 검증이 진행되어야 함
}


# www 서브도메인에 대한 CNAME 레코드
resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id  # 기존 Route 53 호스팅 영역 ID
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.gitlab_alb.dns_name]

  depends_on = [aws_lb.gitlab_alb]  # ALB가 생성된 후에 레코드가 생성되어야 함
}


#로드밸런서 생성

resource "aws_security_group" "alb_sg" {
    name = var.alb_security_group_name
    vpc_id = aws_vpc.gitlab_vpc.id

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = [ var.my_ip ]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ var.my_ip ]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ var.my_ip ]
    }
}

resource "aws_lb" "gitlab_alb" {
    name = var.alb_name

    load_balancer_type = "application"
    subnets = [ aws_subnet.pub_sub_1.id , aws_subnet.pub_sub_2.id ]
    security_groups = [ aws_security_group.alb_sg.id]

    tags = {
      Name = var.alb_name
    }

}


resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.gitlab_alb.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate_validation.example.certificate_arn

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_asg.arn
    }

    depends_on = [aws_acm_certificate_validation.example]  # 인증서 검증이 완료되어야 함    
}

resource "aws_lb_listener_rule" "gitlab" {
    listener_arn = aws_lb_listener.https.arn
    priority	= 100
    condition {
        path_pattern {
            values = ["*"]
        }
    }
    action {
        type	= "forward"
        target_group_arn = aws_lb_target_group.target_asg.arn
    }
    
    depends_on = [aws_lb_listener.https]
}

resource "aws_lb_target_group" "target_asg" {
    name     = var.target_group_name
    port     = 443
    protocol = "HTTPS"
    vpc_id   = aws_vpc.gitlab_vpc.id

    health_check {
        path = "/"
        protocol = "HTTPS"
        interval = 10
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
        matcher = "200,301,302"
    }        

  tags = {
    Name = var.target_group_name
  }

}

# EC2 인스턴스를 Target Group에 등록
resource "aws_lb_target_group_attachment" "gitlab" {
  target_group_arn = aws_lb_target_group.target_asg.arn
  target_id        = aws_instance.gitlab.id
  port             = 443
}





