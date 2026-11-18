# ECR Token Renewer Cronjob

**ECR as helm chart registry for ArgoCD**

In order to use ECR as as `oci://` Helm chart registry with ArgoCD, we need to provide `AWS ECR Token` to ArgoCD. Esentially doing `docker login` or `aws ecr get-login-password`.

The problem is ECR Tokens have a 1 hour session time. And it needs to be put as a Kubernetes Secret, so ArgoCD can read it.

We needed a cronjob that'd get the ECR Token and put it on a Secret.

**AWS Side of things**

We have a single AWS User and it's authorized to assume Cross Account Roles to other digiturk accounts.

So we'd need to assume the role to run `aws ecr get-login-password`.

