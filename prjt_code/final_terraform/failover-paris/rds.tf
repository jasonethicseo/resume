
data "aws_kms_key" "existing_key" {
  key_id = "ae1d4223-8a77-483f-95af-eff0d7d712ef"  # KMS 키 ID를 여기에 입력
}

output "kms_key_arn" {
  value = data.aws_kms_key.existing_key.arn
}



resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.prv_sub_3.id, aws_subnet.prv_sub_4.id]
}

resource "aws_security_group" "aurora_sg" {  
  name        = "aurora-security-group"
  description = "Security group for Aurora MySQL cluster"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
