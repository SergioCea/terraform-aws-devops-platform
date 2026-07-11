resource "aws_s3_bucket" "art_bucket" {
  bucket        = "${var.project_name}-${var.environment}-storage"
  force_destroy = true

  tags = merge(local.common_tags, { Name = "Art Storage Bucket" })
}

resource "aws_s3_bucket_versioning" "versioning_s3" {
  bucket = aws_s3_bucket.art_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "art_bucket" {
  bucket = aws_s3_bucket.art_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3files_file_system" "s3_file_system" {
  bucket   = aws_s3_bucket.art_bucket.arn
  role_arn = aws_iam_role.s3_file_system_role.arn

  tags = {}

  depends_on = [aws_s3_bucket_versioning.versioning_s3]
}

resource "aws_s3files_access_point" "s3_files_system_ap" {
  file_system_id = aws_s3files_file_system.s3_file_system.id
  root_directory {
    path = "/gitea"
    creation_permissions {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {}
}

resource "aws_s3files_access_point" "s3_files_system_sonar_data" {
  file_system_id = aws_s3files_file_system.s3_file_system.id
  root_directory {
    path = "/sonarqube/data"
    creation_permissions {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0700"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {}
}

resource "aws_s3files_access_point" "s3_files_system_sonar_extensions" {
  file_system_id = aws_s3files_file_system.s3_file_system.id
  root_directory {
    path = "/sonarqube/extensions"
    creation_permissions {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0700"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {}
}

resource "aws_s3files_access_point" "s3_files_system_sonar_logs" {
  file_system_id = aws_s3files_file_system.s3_file_system.id
  root_directory {
    path = "/sonarqube/logs"
    creation_permissions {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {}
}

resource "aws_s3files_mount_target" "s3_files_system_mount" {
  file_system_id  = aws_s3files_file_system.s3_file_system.id
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.s3-fs.id]
}

resource "aws_s3files_mount_target" "s3_files_system_mount_2" {
  file_system_id  = aws_s3files_file_system.s3_file_system.id
  subnet_id       = aws_subnet.private_2.id
  security_groups = [aws_security_group.s3-fs.id]
}