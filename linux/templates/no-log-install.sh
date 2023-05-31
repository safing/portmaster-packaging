{{- define "log" }}
{{- end }}

{{ file.Read "templates/arch-base.install" | tmpl.Inline }}