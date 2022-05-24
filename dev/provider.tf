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
    credentials = "./key.json"
    bucket = "zo-backend-tf"
    prefix = "boutique-app/dev"
  }
}

provider "google" {
  credentials = "./key.json"
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  credentials = "./key.json"
  project     = var.project
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
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
  }
}
