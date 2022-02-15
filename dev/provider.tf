terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 5.0, >= 3.45"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "< 5.0, >= 3.45"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.1.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  backend "gcs" {
    # address = "https://gitlab.com/api/v4/projects/32699910/terraform/state/default"
    # lock_address = "https://gitlab.com/api/v4/projects/32699910/terraform/state/default/lock"
    # unlock_address = "https://gitlab.com/api/v4/projects/32699910/terraform/state/default/lock"
    # username = "Ziimm"
    # password = "glpat-y2vAte3yUBNNikaTZdKe"
    # lock_method = "POST"
    # unlock_method = "DELETE"
    # retry_wait_min = 5
    credentials = var.GOOGLE_CREDENTIALS
    # credentials = file(var.gcp_credentials)
    bucket = "backend-bucket-tf-01-333007"
  }
}

provider "google" {
  credentials = var.GOOGLE_CREDENTIALS
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = var.GOOGLE_CREDENTIALS
  project     = var.project_id
  region      = var.region
}

provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}

# ---------
# For GKE
# ---------
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}
