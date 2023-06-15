resource "aws_config_config_rule" "rule" {
  name = "${var.projectname}-ec2-config-rule"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.projectname}-ec2-recorder"
  role_arn = aws_iam_role.role.arn
  recording_group {
    all_supported  = false
    resource_types = ["AWS::EC2::SecurityGroup"]
  }
}

resource "aws_s3_bucket" "channel" {
  bucket        = var.compliance-bucket-store-name
  force_destroy = true
}

resource "aws_config_delivery_channel" "channel" {
  name           = "${var.projectname}-channel"
  s3_bucket_name = aws_s3_bucket.channel.id
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_iam_role" "role" {
  name = "${var.projectname}-awsconfig-ec2-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.projectname}-awsconfig-ec2-policy"
  role = aws_iam_role.role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.channel.arn}",
        "${aws_s3_bucket.channel.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}