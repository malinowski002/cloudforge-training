{{/*
Common labels applied to all resources
*/}}
{{- define "payments.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for payment-api
*/}}
{{- define "payments.api.selectorLabels" -}}
app.kubernetes.io/name: payment-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for payment-worker
*/}}
{{- define "payments.worker.selectorLabels" -}}
app.kubernetes.io/name: payment-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
