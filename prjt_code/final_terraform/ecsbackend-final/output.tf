output "endpoint" {
  value     = aws_rds_cluster.rds_cluster_primary.endpoint
}
output "ro_endpoint" {
  value     = aws_rds_cluster.rds_cluster_primary.reader_endpoint
}

# 주 리전의 RDS 클러스터 ARN을 출력
output "primary_rds_cluster_arn" {
  value = aws_rds_cluster.rds_cluster_primary.arn
}