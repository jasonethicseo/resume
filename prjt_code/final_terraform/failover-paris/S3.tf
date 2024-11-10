# 백엔드 버킷 생성
resource "aws_s3_bucket" "codedeploy_backend_bucket" {
  bucket = "codedeploy-970728-backend-paris"
  
  tags = {
    Name        = "codedeploy-970728-backend-paris"
    Environment = "development"
  }
  
}  

resource "aws_s3_bucket_server_side_encryption_configuration" "codedeploy_backend_bucket_encryption" {
  bucket = aws_s3_bucket.codedeploy_backend_bucket.id  

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}




# 백엔드 버킷의 버전 관리 설정
resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.codedeploy_backend_bucket.id

  versioning_configuration {
    status = "Enabled"  # 버전 관리를 활성화
  }
}

# 백엔드 버킷의 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "backend_block" {
  bucket = aws_s3_bucket.codedeploy_backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
