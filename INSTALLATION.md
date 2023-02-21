# Installation Guide

## Prerequisite

- Install Terraform
    + See https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform
- AWS CLI and Configuration
    + See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    + See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

...

## Initial Setup

After cloning the repository, `cd` into the `infra/` folder and run the following. Once the Terraform configuration is applied, it'll create two EC2 instances. The Kubernetes setup in these instances will take a couple of minutes.

```bash
# Make sure to set the AWS_PROFILE. Otherwise, it'll use your default config.
# The stack will be applied to `us-west-2` region. This can be changed in `insta/main.tf`.
$ export AWS_PROFILE=<YOUR_PROFILE_NAME>

# Initialize Terraform and install providers
$ terraform init

# To see the plan
$ terraform plan

# To apply the configuration
$ terraform apply -auto-approve
```

After running this, the state of these instances can be followed by connecting to the instances.

```bash
# This will open up a session to the given instance.
$ aws ssm start-session --target <INSTANCE_ID> --region us-west-2

# Once the connection is established, you can switch to `ubuntu` user.
$ sudo su - ubuntu

# To follow the status of the init script, you can follow the logs
# in this location.
$ sudo tail -f /var/log/cloud-init-output.log

# You can check the status of the nodes inside the machine by running
$ kubectl get nodes
```

## CI Setup

To prepare the GitHub Action to run our deployments, we need some things. If you fork the repository, you must set the following secrets. You'd also need to update [rollout.yml](./.github/workflows/rollout.yml) to use your Docker username.

> To access the secret settings for your fork, visit the following URL:
> https://github.com/<YOUR_USERNAME>/vops-testing/settings/secrets/actions

- DOCKERHUB_PASSWORD
    + Can be generated at: https://hub.docker.com/settings/security
- CLUSTER_GHA_SECRET
    + Once the Terraform configuration is applied and cluster starts running, this secret can be fetched from AWS SSM using the following command.
        ```bash
        aws ssm get-parameters \
            --with-decryption \
            --name kubernetes-cluster-secret \
            --region us-west-2 \
            | jq -r '.Parameters[0].Value'
        ```
- CLUSTER_API_ENDPOINT
    + Similar to the secret above, endpoint can be fetched from AWS SSM.
        ```bash
        aws ssm get-parameters \
            --with-decryption \
            --name kubernetes-cluster-api-address \
            --region us-west-2 \
            | jq -r '.Parameters[0].Value'
        ```

At this point, the GitHub Action is ready to run and deploy our application. You can go to `https://github.com/<YOUR_USERNAME>/vops-testing/actions/workflows/rollout.yml` and run the workflow.

You can also run [utils/set-kubeconfig.sh](./utils/set-kubeconfig.sh) to set up the Kube context in locally. **Beware that this will replace your existing configuration and it'll move it as `config-$(date +%s%3N).bak`**. Also make sure to set your `AWS_PROFILE` for your shell session.

## Destroying Resources

To destroy the resources we create, again, `cd` into `infra/` directory and run the following.

```bash
$ export AWS_PROFILE=<YOUR_PROFILE_NAME>

$ terraform destroy -auto-approve
```

As we create some parameters while initializing our instances, those resources should be deleted separately. To destroy these resources, run the following.

```bash
$ export AWS_PROFILE=<YOUR_PROFILE_NAME>

$ aws ssm delete-parameters \
    --names \
        kubernetes-cluster-kubeconfig \
        kubernetes-cluster-api-address \
        kubernetes-cluster-tmp-join-command \
        kubernetes-cluster-secret \
    --region us-west-2
```
