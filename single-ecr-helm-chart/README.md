# ECR Token Renewer Cronjob

**ECR as a Helm chart registry for Argo CD**

To use ECR as an `oci://` Helm chart registry with Argo CD, Argo CD needs an AWS ECR token in a Kubernetes Secret. That is the same credential `aws ecr get-login-password` returns.

ECR authorization tokens last 12 hours. This chart runs a CronJob that fetches one token for the account and writes an Argo CD Secret for each repository in `repositories`.

**AWS side**

The CronJob uses one IAM user's access key and secret key for the single AWS account that owns the registry. Supply `aws_access_key_id_base64` and `aws_secret_access_key_base64` from Argo CD. Do not commit real keys in `values.yaml`.

The IAM user needs `ecr:GetAuthorizationToken` in that account. There is no cross-account role and no IRSA annotation.

`ecrRegistry` is the registry host. Each `repositories` entry sets `path` (the repository path in that registry) and `name` (the Argo CD display name). The Secret URL is `<ecrRegistry>/<path>`. The token is registry-scoped, so every Secret gets the same password from one `get-login-password` call.

Add as many entries as you need:

```yaml
repositories:
  - name: "ECR charts"
    path: charts
  - name: "ECR app"
    path: team/app
```

Secret object names are derived from `path` (`/` becomes `-`). Paths must stay unique after that replacement.

The CronJob applies the Argo CD repository Secrets (`argocd.argoproj.io/secret-type: repository`). Helm does not own those Secrets, so the next run can refresh the passwords in place.
