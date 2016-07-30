resource "aws_iam_role" "node" {
    name = "${var.efs_test_name}-node"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "node" {
    name = "${var.efs_test_name}-node"
    role = "${aws_iam_role.node.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "s3:Delete*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "node" {
    name  = "${var.efs_test_name}-node"
    roles = ["${aws_iam_role.node.name}"]
}
