provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "datos" {
  description         = "Llave para RDS y S3 del portal Drupal"
  enable_key_rotation = true
}

# ---------- S3 (HC05) ----------
resource "aws_s3_bucket" "archivos" {
  bucket = "umg-drupal-archivos-lab"
}

resource "aws_s3_bucket_public_access_block" "archivos" {
  bucket                  = aws_s3_bucket.archivos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "archivos" {
  bucket = aws_s3_bucket.archivos.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.datos.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "archivos" {
  bucket = aws_s3_bucket.archivos.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ---------- Security Group sin SSH publico (HC06) ----------
resource "aws_security_group" "web" {
  name        = "drupal-web"
  description = "Trafico HTTPS desde el balanceador interno"
  ingress {
    description = "HTTPS desde la VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# ---------- RDS privada y cifrada (HC04, HC17, HC02) ----------
resource "aws_db_instance" "drupal" {
  identifier                          = "drupal-db"
  engine                              = "mysql"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 20
  username                            = "drupal_admin"
  manage_master_user_password         = true
  publicly_accessible                 = false
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.datos.arn
  iam_database_authentication_enabled = true
  deletion_protection                 = true
  backup_retention_period             = 7
  multi_az                            = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = aws_kms_key.datos.arn
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "drupal-db-final"
}
