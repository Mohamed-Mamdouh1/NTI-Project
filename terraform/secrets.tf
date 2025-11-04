resource "aws_secretsmanager_secret" "db_secret" {
  name = "nti-db-credentials1"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.nti_rds.username
    password = aws_db_instance.nti_rds.password
  })
}