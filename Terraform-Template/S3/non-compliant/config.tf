// Config rule
resource "aws_config_config_rule" "rule" {
  name = "${var.projectname}-s3-config-rule"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder.recorder]
}


// Specify the recorder to monitor only s3 resource
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.projectname}-s3-recorder"
  role_arn = aws_iam_role.role.arn
  recording_group {
    all_supported  = false
    resource_types = ["AWS::S3::Bucket"]
  }
}

// Start the recorder
resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}


//Delivery Channel bucket
resource "aws_s3_bucket" "channel" {
  bucket        = var.compliance-bucket-store-name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket_config_acl" {
  bucket = aws_s3_bucket.channel.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.channel.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Delivery channel
resource "aws_config_delivery_channel" "channel" {
  name           = "${var.projectname}-s3-delivery-channel"
  s3_bucket_name = aws_s3_bucket.channel.id
  depends_on     = [aws_config_configuration_recorder.recorder]
}


//Role and policy
resource "aws_iam_role" "role" {
  name               = "${var.projectname}-awsconfig-s3-role"
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
  name = "${var.projectname}-awsconfig-s3-policy"
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
