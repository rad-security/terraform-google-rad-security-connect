locals {
  project_name   = coalesce(var.gcp_project_name, data.google_project.current.project_id)
  project_number = coalesce(var.gcp_project_number, data.google_project.current.number)
}
