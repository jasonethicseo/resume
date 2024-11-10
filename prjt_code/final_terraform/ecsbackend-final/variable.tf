variable "aws_region" {
  default = "ca-central-1"
}


variable "alb_security_group_name" {
    description = "The name of the ALB's security group"
    type = string
    default = "gitlab-alb-sg-970728"
}

variable "alb_name" {
    description = "name of ALB"
    type = string
    default = "gitlab-alb-970728"
}

variable "my_ip" { 
    description = "My public IP" 
    type	= string
    default	= "0.0.0.0/0"
}

variable "server_port" {
    description = "Webserver’s HTTP port"
    type	= number
    default	= 80
}

variable "target_group_name" {
    description = "gitlab's target group name"
    type = string
    default = "gitlab-alb-tg-970728"
}
variable "domain_name" {
    description = "ACM cert domain name"
    type = string
    default = "gitlab.jasonseo.site"
}

variable "route53_zone_id" {
    description = "The ID of the existing Route 53 hosted zone."
    type        = string
    default     = "Z08774531OMTKYN3QLX3V"  # 기존 호스팅 영역 ID
}

variable "prefix_name" {
  type    = string
  default = "dev"
}

variable "ecs_ec2_volume_size" {
  type    = number
  default = 20
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "development"
    Application = "my-app"
  }
}

locals {
  region          = "ca-central-1"                  # AWS 리전을 한 곳에서 정의
  ecs_cluster_name = "ecs-cluster-${var.prefix_name}" # ECS 클러스터 이름
  volume_name     = "${var.prefix_name}-volume"     # ECS 작업 정의에서 사용할 볼륨 이름
}

variable "db_master_password" {
  description = "The master password for the RDS cluster"
  type        = string
  sensitive   = true  # 민감한 정보로 설정
}

