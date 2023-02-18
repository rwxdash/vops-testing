resource "aws_instance" "k8s_master_node" {
  # Fixing the AMI to
  #     ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230213
  #     ami-0ee3d9a8776e8b99c
  ami                         = "ami-0ee3d9a8776e8b99c"
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.k8s_node_role.name
  user_data_replace_on_change = true
  user_data                   = file("./scripts/init.sh")

  tags = {
    Name = "k8s-master-node-dev"
  }
}

# resource "aws_instance" "k8s-worker-node-01" {
#   # Fixing the AMI to
#   #     ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230213
#   #     ami-0ee3d9a8776e8b99c
#   ami                  = "ami-0ee3d9a8776e8b99c"
#   instance_type        = "t2.micro"
#   iam_instance_profile = aws_iam_instance_profile.k8s-node-role.name

#   tags = {
#     Name = "k8s-worker-node-01-dev"
#   }
# }
