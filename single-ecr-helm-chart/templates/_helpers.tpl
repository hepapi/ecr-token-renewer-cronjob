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


{{- define "ecrCronjob.secretName" -}}
ecr-creds-sync-aws-credentials
{{- end }}

{{- define "ecrCronjob.repoSecretName" -}}
{{- $safe := .path | lower | replace "/" "-" | replace "_" "-" | replace "." "-" | trimAll "-" -}}
{{- printf "%s-%s" .prefix $safe | trunc 63 | trimSuffix "-" -}}
{{- end }}
