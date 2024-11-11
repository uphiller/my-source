resource "aws_opensearch_domain" "example" {
  domain_name    = "test"
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type  = "r5.large.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = "Admin1234!"
    }
  }

  access_policies = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "es:*"
        "Resource" : "arn:aws:es:ap-northeast-2:193945198166:domain/test/*"
      }
    ]
  })
}

resource "aws_iam_role" "ingestion_pipeline_role" {
  name = "opentelemetry_ingestion_pipeline_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "osis-pipelines.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ingestion_pipeline_policy" {
  name        = "ingestion_pipeline_policy"
  description = "Policy to allow Ingestion Pipeline to write to OpenSearch"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet",
          "es:ESHttpDelete",
          "es:DescribeDomain",  # OpenSearch 도메인에 대한 설명 권한
          "es:DescribeDomainConfig",  # 도메인 설정에 대한 설명 권한
          "es:ListDomainNames"  # 도메인 목록을 조회하는 권한
        ],
        Resource = "arn:aws:es:ap-northeast-2:193945198166:domain/test"
      }
    ]
  })

  depends_on = [aws_iam_role.ingestion_pipeline_role]
}

resource "aws_iam_role_policy_attachment" "ingestion_pipeline_attach_policy" {
  role       = aws_iam_role.ingestion_pipeline_role.name
  policy_arn = aws_iam_policy.ingestion_pipeline_policy.arn
}

#option
#https://opensearch.org/docs/latest/data-prepper/pipelines/configuration/sources/otel-logs-source/
#Role
#arn:aws:iam::193945198166:role/opentelemetry_ingestion_pipeline_role
resource "aws_osis_pipeline" "opentelemetry_pipeline" {
  pipeline_name               = "opentelemetry-pipeline"
  min_units                   = 1
  max_units                   = 2

  pipeline_configuration_body = jsonencode({
    "version": "2",
    "otel-logs-pipeline": {
      "source": {
        "otel_logs_source": {
          "path": "/opentelemetry.proto.collector.logs.v1.LogsService/Export"
        }
      },
      "sink": [
        {
          "opensearch": {
            "hosts": [
              "https://search-test-vurdl74lxapmmxj3y5o36pvxfq.ap-northeast-2.es.amazonaws.com"
            ],
            "aws": {
              "sts_role_arn": "arn:aws:iam::193945198166:role/opentelemetry_ingestion_pipeline_role",
              "region": "ap-northeast-2",
              "serverless": false
            },
            "index": "logs-%%{yyyy-MM-dd}",
          }
        }
      ]
    }
  })

  depends_on = [aws_iam_role_policy_attachment.ingestion_pipeline_attach_policy]
}
