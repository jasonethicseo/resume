resource "aws_ecr_repository" "ecs_prjt_back_970728" {
  name                 = "ecs-prjt-back-970728"  # 리포지토리의 이름을 설정합니다.
  image_tag_mutability = "MUTABLE"             # 이미지 태그의 변경 가능 여부를 설정합니다. (MUTABLE 또는 IMMUTABLE)

  image_scanning_configuration {
    scan_on_push = true                        # 이미지를 푸시할 때 스캔을 활성화합니다.
  }

  tags = {
    Environment = "backend"                 # 리포지토리에 태그를 추가합니다.
  }
}
