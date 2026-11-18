{{- define "namespace" -}}
{{- if .Values.namespaceOverride -}}
{{- .Values.namespaceOverride -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end }}

{{- define "ecrCronjob.name" -}}
{{- default "ecr-creds-sync" .Values.name -}}
{{- end }}

{{- define "ecrCronjob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "ecrCronjob.labels" -}}
helm.sh/chart: {{ include "ecrCronjob.chart" . }}
app.kubernetes.io/name: {{ include "ecrCronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ecrCronjob.secretName" -}}
ecr-creds-sync-aws-credentials
{{- end }}

{{- define "ecrCronjob.repoSecretName" -}}
{{- $safe := .path | lower | replace "/" "-" | replace "_" "-" | replace "." "-" | trimAll "-" -}}
{{- printf "%s-%s" .prefix $safe | trunc 63 | trimSuffix "-" -}}
{{- end }}
