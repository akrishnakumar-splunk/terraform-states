variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

variable "aws_dynamodb_table" {
  default = "vsph-tfstatelock"
}

variable "aws_state_bucket" {
  default = "vsph-states-bucket"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "vsph_bucket" {
  bucket        = "${var.aws_state_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.vsphere_user.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_state_bucket}",
                "arn:aws:s3:::${var.aws_state_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "vsphere_user" {
  name = "vsphereuser"
}

resource "aws_iam_access_key" "vsphere_user" {
  user = "${aws_iam_user.vsphere_user.name}"
}

resource "aws_iam_user_policy" "vsphere_user_rw" {
  name = "vsphereuser"
  user = "${aws_iam_user.vsphere_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_state_bucket}",
                "arn:aws:s3:::${var.aws_state_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    "${aws_iam_user.vsphere_user.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

output "vsphere_admin-access-key" {
  value = "${aws_iam_access_key.vsphere_user.id}"
}

output "vsphere_admin-secret-key" {
  value = "${aws_iam_access_key.vsphere_user.secret}"
}
