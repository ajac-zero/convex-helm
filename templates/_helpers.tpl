{{/*
Expand the name of the chart.
*/}}
{{- define "convex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "convex.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "convex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "convex.labels" -}}
helm.sh/chart: {{ include "convex.chart" . }}
{{ include "convex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "convex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "convex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "convex.backend.labels" -}}
{{ include "convex.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "convex.backend.selectorLabels" -}}
{{ include "convex.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Dashboard labels
*/}}
{{- define "convex.dashboard.labels" -}}
{{ include "convex.labels" . }}
app.kubernetes.io/component: dashboard
{{- end }}

{{/*
Dashboard selector labels
*/}}
{{- define "convex.dashboard.selectorLabels" -}}
{{ include "convex.selectorLabels" . }}
app.kubernetes.io/component: dashboard
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "convex.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create }}
{{- default (include "convex.fullname" .) .Values.backend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.backend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend fullname
*/}}
{{- define "convex.backend.fullname" -}}
{{- printf "%s-backend" (include "convex.fullname" .) }}
{{- end }}

{{/*
Dashboard fullname
*/}}
{{- define "convex.dashboard.fullname" -}}
{{- printf "%s-dashboard" (include "convex.fullname" .) }}
{{- end }}

{{/*
Secret name for instance credentials
*/}}
{{- define "convex.secretName" -}}
{{- if .Values.instance.existingSecret }}
{{- .Values.instance.existingSecret }}
{{- else }}
{{- printf "%s-secret" (include "convex.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Secret name for database credentials
*/}}
{{- define "convex.databaseSecretName" -}}
{{- if eq .Values.database.type "postgres" }}
{{- if .Values.database.postgres.existingSecret }}
{{- .Values.database.postgres.existingSecret }}
{{- else }}
{{- printf "%s-db-secret" (include "convex.fullname" .) }}
{{- end }}
{{- else if eq .Values.database.type "mysql" }}
{{- if .Values.database.mysql.existingSecret }}
{{- .Values.database.mysql.existingSecret }}
{{- else }}
{{- printf "%s-db-secret" (include "convex.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Secret name for S3 credentials
*/}}
{{- define "convex.s3SecretName" -}}
{{- if .Values.storage.s3.existingSecret }}
{{- .Values.storage.s3.existingSecret }}
{{- else }}
{{- printf "%s-s3-secret" (include "convex.fullname" .) }}
{{- end }}
{{- end }}

{{/*
PVC name
*/}}
{{- define "convex.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- printf "%s-data" (include "convex.fullname" .) }}
{{- end }}
{{- end }}

{{/*
ConfigMap name
*/}}
{{- define "convex.configMapName" -}}
{{- printf "%s-config" (include "convex.fullname" .) }}
{{- end }}
