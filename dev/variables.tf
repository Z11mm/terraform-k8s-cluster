# ------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------

variable "project_id" {
  default     = "deimos-gcp-explore-01-333007"
  description = "The id of the target project to provision infrastructure"
  type        = string
}

variable "GOOGLE_CREDENTIALS" {
  type        = string
}

variable "region" {
  default     = "us-west1"
  description = "The default region for the project"
  type        = string
}

# variable "network_name" {
#   default     = "gke-cluster-vpc"
#   description = "The name of the vpc network"
#   type        = string
# }

variable "environment" {
  default     = "development"
  description = "The current working environment"
  type        = string
}
