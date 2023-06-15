resource "aws_iam_role" "ssm" {
  name = "my-awsssm-role"

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
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSecurityGroupRules",
        "ec2:ModifySecurityGroupRules"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

//Remediation
resource "aws_config_remediation_configuration" "remediation" {
  config_rule_name = aws_config_config_rule.rule.name
  resource_type    = "AWS::EC2::SecurityGroup"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisablePublicAccessForSecurityGroup"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.ssm.arn
  }
  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 600
}