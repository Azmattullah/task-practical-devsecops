variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-south1-c"
}

variable "gke_machine_type" {
  description = "GCE Machine Type (mapped from requested gke_machine_type)"
  type        = string
  default     = "e2-medium"
}

variable "gke_disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "gke_disk_type" {
  description = "Disk type"
  type        = string
  default     = "pd-standard"
}
