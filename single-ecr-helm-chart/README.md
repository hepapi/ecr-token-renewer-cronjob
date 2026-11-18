# ECR Token Renewer Cronjob

**ECR as a Helm chart registry for Argo CD**

To use ECR as an `oci://` Helm chart registry with Argo CD, Argo CD needs an AWS ECR token in a Kubernetes Secret. That is the same credential `aws ecr get-login-password` returns.

ECR authorization tokens last 12 hours. This chart runs one CronJob on `0 */8 * * *` (every 8 hours, `Asia/Istanbul`). That leaves a second chance before the token expires. The job fetches one token for the account and writes an Argo CD Secret for each repository in `repositories`.

**AWS side**

The CronJob uses one IAM user's access key and secret key for the single AWS account that owns the registry. `aws_access_key_id_base64` and `aws_secret_access_key_base64` must be base64, because they are stored in a Secret `data` field. Leave them empty in git and set them from Argo CD.

The IAM user needs `ecr:GetAuthorizationToken` in that account. There is no cross-account role and no IRSA annotation.

`ecrRegistry` is the registry host. Each `repositories` entry sets `path` (the repository path in that registry) and `name` (the Argo CD display name). The Secret URL is `<ecrRegistry>/<path>`. The token is registry-scoped, so every Secret gets the same password from one `get-login-password` call.

```yaml
repositories:
  - name: "ECR charts"
    path: charts
  - name: "ECR app"
    path: team/app
```

Secret object names are derived from `path` (`/`, `_`, and `.` become `-`). Paths must stay unique after that replacement.

The CronJob builds each repository Secret with `kubectl create secret generic --from-literal --dry-run=client` and applies it. Helm does not own those Secrets, so the next run can refresh the passwords in place. The password is passed as a quoted shell variable, so token characters are not interpreted by the shell.

**Runtime**

`amazon/aws-cli` is pinned to `2.41.0`. `bitnami/kubectl` is pinned by digest because Docker Hub no longer publishes version tags for that image. Both containers run as non-root with a read-only root filesystem. The token and temporary files stay on in-memory `emptyDir` volumes.

The job uses `concurrencyPolicy: Forbid`, keeps three successful and three failed runs, and stops after 10 minutes. The ServiceAccount can `create` Secrets in the namespace. `get`, `patch`, and `update` are limited to the repository Secret names from `repositories`.

Set `namespaceOverride` to a namespace string to install outside the release namespace. Leave it empty to use the release namespace.

**Failed renewals**

A missed run is quiet until Argo CD cannot pull. Set `monitoring.prometheusRule.enabled` to `true` when the Prometheus Operator CRD and kube-state-metrics are installed. Add the labels your Prometheus selects under `monitoring.prometheusRule.labels`.

The rule alerts when a job has failed, and when the last success is older than `monitoring.prometheusRule.staleAfterSeconds` (default 10 hours).
