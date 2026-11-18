{{- define "namespace" -}}
{{- if .Values.namespaceOverride -}}
{{- .Values.namespaceOverride -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end }}

{{- define "ecrCronjob.name" -}}
ecr-creds-sync-{{.clusterName}}
{{- end }}


{{- define "ecrCronjob.secretName" -}}
ecr-creds-sync-aws-credentials
{{- end }}


{{- define "bein-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bein-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "bein-service.labels" -}}
helm.sh/chart: {{ include "bein-service.chart" . }}
{{ include "bein-service.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | trimall "'" | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}



{{- define "bein-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}