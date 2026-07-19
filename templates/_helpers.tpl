{{/*
Expand the name of the chart.
*/}}
{{- define "home-assistant.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "home-assistant.fullname" -}}
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
{{- define "home-assistant.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "home-assistant.labels" -}}
helm.sh/chart: {{ include "home-assistant.chart" . }}
{{ include "home-assistant.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "home-assistant.selectorLabels" -}}
app.kubernetes.io/name: {{ include "home-assistant.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Volumes for extraConfigMounts (ConfigMap/Secret directory mounts under /config).
Context is the .Values.extraConfigMounts list. Callers should guard with `with`.
*/}}
{{- define "home-assistant.extraConfigVolumes" -}}
{{- range . }}
- name: {{ .name }}
  {{- if .configMap }}
  configMap:
    name: {{ .configMap }}
    {{- if hasKey . "defaultMode" }}
    defaultMode: {{ .defaultMode }}
    {{- end }}
    {{- if hasKey . "optional" }}
    optional: {{ .optional }}
    {{- end }}
  {{- else if .secret }}
  secret:
    secretName: {{ .secret }}
    {{- if hasKey . "defaultMode" }}
    defaultMode: {{ .defaultMode }}
    {{- end }}
    {{- if hasKey . "optional" }}
    optional: {{ .optional }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
volumeMounts for extraConfigMounts. Directory mounts (no subPath) so ConfigMap
updates propagate live. Context is the .Values.extraConfigMounts list.
*/}}
{{- define "home-assistant.extraConfigVolumeMounts" -}}
{{- range . }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
  {{- if .subPath }}
  subPath: {{ .subPath }}
  {{- end }}
  readOnly: {{ .readOnly | default true }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "home-assistant.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "home-assistant.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
