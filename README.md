# vops-testing

Goal is to understand self-managed Kubernetes.

# todo

- [x] Create a Terraform configuration to provision cluster nodes.
    - 1 Master Node and 1 Worker Node.
    - Master node needs min. 2 vCPUs. Use t3.small.
    - Worker node can be t2.micro.
    - Necessary libraries and configurations can be set up using user datas.
- [x] Create a master node using kubeadm.
    - For now, share the generated kubeconfig and temporary kubeadm join command using AWS SSM. The user data can put these values to AWS SSM.
- [x] Create a worker node and attach it to the existing cluster.
    - The kubeconfig and temporary join command can be fetched from AWS SSM. This is temporary until we figure something more conventional.
    - A drawback at this point is to make sure that the SSM parameters are correctly set up.
- [x] A sample dockerized application.
    - The application needs a persistant database.
- [ ] Application must be deployable via CI/CD.
    - Build and deploy Docker image to DockerHub.
    - Apply kubernetes deployment to the cluster to pull new image.

# things to figure out

- Currently, the cluster runs inside a default VPC. Maybe a better network configuration needed.
- The application deployed must be accessible from outside. The node security groups might need adjustments.
- Automate deployments. Not sure I want to automate the infra deployments yet.
- A way to get the kubeadm join command from the worker node. As the token itself can be expired, the command in the AWS SSM Parameter Store become obsolete.
- The kubeconfig we push to AWS SSM Parameter Store, uses the private IPv4 address. When working on local environment or on CI, this might cause issues as it would need replacement.
- The application needs ingress or external IP to be accessible from the internet.
