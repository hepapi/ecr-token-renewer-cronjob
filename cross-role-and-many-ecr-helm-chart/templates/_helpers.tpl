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


{{- define "ecrrenewerjob.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ecrrenewerjob.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "ecrrenewerjob.labels" -}}
helm.sh/chart: {{ include "ecrrenewerjob.chart" . }}
{{ include "ecrrenewerjob.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | trimall "'" | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}



{{- define "ecrrenewerjob.fullname" -}}
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