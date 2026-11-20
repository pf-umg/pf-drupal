provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "archivos" {
  bucket = "umg-drupal-archivos-lab"
}

resource "aws_security_group" "web" {
  name = "drupal-web"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "drupal" {
  identifier          = "drupal-db"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "Cambiar123!"
  publicly_accessible = true
  storage_encrypted   = false
  skip_final_snapshot = true
}
