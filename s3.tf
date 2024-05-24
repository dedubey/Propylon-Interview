module "s3_bucket_ec2" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "ec2-access-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "ec2_bucket_policy" {
  bucket = module.s3_bucket_ec2.s3_bucket_id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2-role.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:*"
        ],
        "Resource": [
          "arn:aws:s3:::ec2-access-bucket-902362636025/*",
          "arn:aws:s3:::ec2-access-bucket-902362636025"
        ]
      }
    ]
  })
  depends_on = [aws_iam_role.ec2-role]
}