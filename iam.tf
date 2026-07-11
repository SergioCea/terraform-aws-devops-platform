resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role-gitea"

  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.db_gitea_pw.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:/ecs/*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_gitea_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role-gitea"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_gitea_s3_role_policy" {
  role       = aws_iam_role.ecs_task_gitea_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FilesClientFullAccess"
}

resource "aws_iam_role_policy" "ecs_task_gitea_s3_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_gitea_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "S3ObjectReadAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        "Resource" : ["${aws_s3_bucket.art_bucket.arn}/gitea/*"]
      },
      {
        "Sid" : "S3BucketListAccess",
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : [aws_s3_bucket.art_bucket.arn]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_sonarqube_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role-sonarqube"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_sonarqube_s3_role_policy" {
  role       = aws_iam_role.ecs_task_sonarqube_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FilesClientFullAccess"
}

resource "aws_iam_role_policy" "ecs_task_sonarqube_s3_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_sonarqube_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "S3ObjectReadAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        "Resource" : ["${aws_s3_bucket.art_bucket.arn}/sonarqube/*"]
      },
      {
        "Sid" : "S3BucketListAccess",
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : [aws_s3_bucket.art_bucket.arn]
      }
    ]
  })
}

resource "aws_iam_role" "s3_file_system_role" {
  name = "${var.project_name}-${var.environment}-s3-file-system-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowS3FilesAssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "elasticfilesystem.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : local.account_id
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:s3files:${local.region}:${local.account_id}:file-system/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_file_system_role_policy" {
  name = "S3FilesGiteaPolicy"
  role = aws_iam_role.s3_file_system_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3BucketPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket*"
        ],
        "Resource" : aws_s3_bucket.art_bucket.arn,
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "S3ObjectPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject*",
          "s3:GetObject*",
          "s3:List*",
          "s3:PutObject*"
        ],
        "Resource" : "${aws_s3_bucket.art_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : local.account_id
          }
        }
      },
      {
        "Sid" : "UseKmsKeyWithS3Files",
        "Effect" : "Allow",
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ],
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "s3.${local.region}.amazonaws.com",
            "kms:EncryptionContext:aws:s3:arn" : [
              aws_s3_bucket.art_bucket.arn,
              "${aws_s3_bucket.art_bucket.arn}/*"
            ]
          }
        },
        "Resource" : "arn:aws:kms:${local.region}:${local.account_id}:*"
      },
      {
        "Sid" : "EventBridgeManage",
        "Effect" : "Allow",
        "Action" : [
          "events:DeleteRule",
          "events:DisableRule",
          "events:EnableRule",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets"
        ],
        "Condition" : {
          "StringEquals" : {
            "events:ManagedBy" : "elasticfilesystem.amazonaws.com"
          }
        },
        "Resource" : [
          "arn:aws:events:*:*:rule/DO-NOT-DELETE-S3-Files*"
        ]
      },
      {
        "Sid" : "EventBridgeRead",
        "Effect" : "Allow",
        "Action" : [
          "events:DescribeRule",
          "events:ListRuleNamesByTarget",
          "events:ListRules",
          "events:ListTargetsByRule"
        ],
        "Resource" : [
          "arn:aws:events:*:*:rule/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role_keycloak" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role-keycloak"

  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_keycloak_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role_keycloak.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_keycloak_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role_keycloak.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.db_keycloak_pw.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:/ecs/*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role_sonarqube" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role-sonarqube"

  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_sonarqube_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role_sonarqube.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_sonarqube_policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role_sonarqube.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.db_sonarqube_pw.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:/ecs/*"
      }
    ]
  })
}