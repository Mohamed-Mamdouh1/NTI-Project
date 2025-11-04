resource "aws_db_instance" "nti_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "ntidb"
  username             = "admin"
  password             = "NTIpass123!"
  skip_final_snapshot  = true
  publicly_accessible  = true
  deletion_protection  = false
  backup_retention_period = 0
}