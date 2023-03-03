# vops-testing

Goal is to understand self-managed Kubernetes.kk

# unfinished parts and improvements

- Application isn't exposed to the internet. Since we're on bare metal, service type `LoadBalancer` won't create LoadBalancer automatically. I haven't figured out how to make it work yet.
- Better scripting around etting up the Kube config file. The utility file `./utils/set-kubeconfig.sh` will set up the existing configuration file from AWS SSM. However, this file has the private IP address of our instance as its `server` value. This needs to be changed manually to public IP of our master node instance if we want to work on our cluster locally. Another way would be to create a secret, similar to the secret we use in our CI and generate the kube config from this secret.
- Maybe it's better to trigger our CI automatically when there is a push to our master branch.
- If at any point, our worker node restarts or we want to create new worker nodes, the existing `kubeadm join` command and its token could be expired.


# todo

- [ ] Expose applications to the public internet.
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
- [x] Application must be deployable via CI/CD.
    - Build and deploy Docker image to DockerHub.
    - Apply kubernetes deployment to the cluster to pull new image.


# things to figure out

- Currently, the cluster runs inside a default VPC. Maybe a better network configuration needed.
- The application deployed must be accessible from outside. The node security groups might need adjustments.
- Automate deployments. Not sure I want to automate the infra deployments yet.
- A way to get the kubeadm join command from the worker node. As the token itself can be expired, the command in the AWS SSM Parameter Store become obsolete.
- The kubeconfig we push to AWS SSM Parameter Store, uses the private IPv4 address. When working on local environment or on CI, this might cause issues as it would need replacement.
- The application needs ingress or external IP to be accessible from the internet.

# nice to have

- Use helm charts for kubernetes resources
    + Bitnami helm chart
- Use ansible to provision cluster node
    + https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/
    + https://ranchermanager.docs.rancher.com/v2.5/getting-started/quick-start-guides/deploy-rancher-manager/aws
- Secret usage can be improved. eg. mysql
- dev/stage/prod stage splits
- Pipeline chart/diagram
- Test stage with sonarcube
