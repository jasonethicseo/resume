resource "aws_cloudwatch_log_group" "ecs_logs_2" {
  name = "/ecs/prjt-back"  # 로그 그룹 이름

  retention_in_days = 30   # 로그 보존 기간 (일 단위)
}

resource "aws_ecs_task_definition" "ecs_prjt_task_definition_back" {
  family                   = "ecs-prjt-back-taskdef-970728"  # 태스크 정의의 이름
  network_mode             = "awsvpc"
  cpu                      = "1024"            # 1 vCPU
  memory                   = "3072"            # 3 GB 메모리
  requires_compatibilities = ["EC2"]           # EC2 인스턴스에서 실행되는 태스크
  execution_role_arn       = "arn:aws:iam::971422701599:role/ecsTaskExecutionRole"  # 기존에 만들어진 역할의 ARN


  container_definitions = jsonencode([
    {
      name      = "backend"  # 컨테이너 이름
      image     = "971422701599.dkr.ecr.eu-west-3.amazonaws.com/ecs-prjt-back-970728"  # 컨테이너 이미지 URI
      cpu       = 1024
      memory    = 3072
      essential = true
      portMappings = [
        {
          containerPort = 8080  # 컨테이너 포트

          ####awsvpc에서 얘 추가
          hostPort      = 8080  # 호스트 포트 동적할당
          protocol      = "tcp"  # 프로토콜
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/prjt-back"
          "awslogs-region"        = "eu-west-3"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


