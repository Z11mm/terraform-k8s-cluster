# ------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------

variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

# variable "GOOGLE_CREDENTIALS" {
#   type        = string
# }

variable "region" {
  description = "The default region for the project"
  type        = string
}

variable "environment" {
  description = "The current working environment"
  type        = string
}
