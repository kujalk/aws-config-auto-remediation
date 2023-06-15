resource "aws_iam_role" "ssm" {
  name = "${var.projectname}-s3-awsssm-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ssm" {
  name = "awsssm-example"
  role = aws_iam_role.ssm.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetBucketPublicAccessBlock"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

//Remediation
resource "aws_config_remediation_configuration" "this" {
  config_rule_name = aws_config_config_rule.rule.name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.ssm.arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }


  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 600
}