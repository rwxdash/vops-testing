resource "aws_iam_role" "k8s_node_role" {
  name = "k8s_node_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole",
      "Sid": ""
    },
    {
      "Effect":"Allow",
      "Principal": {
          "Service":"ssm.amazonaws.com"
      },
      "Action":"sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonSSMFullAccess" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2FullAccess" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "k8s_node_role" {
  name = "k8s_node_role"
  role = aws_iam_role.k8s_node_role.name
}
