# # ---------------------------------------------------------------------------------------
# # CREATE VPC NETWORK
# # ---------------------------------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "vpc_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id              = var.project_id
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu                     = var.mtu

  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}
# module "vpc_network" {
#   source = "github.com/gruntwork-io/terraform-google-network.git//modules/vpc-network?ref=v0.8.2"

#   name_prefix = "${var.cluster_name}-${random_string.suffix.result}-${var.environment}"
#   project     = var.project
#   region      = var.region

#   cidr_block = var.vpc_cidr_block

#   public_subnetwork_secondary_range_name = var.public_subnetwork_secondary_range_name
#   public_services_secondary_range_name   = var.public_services_secondary_range_name
#   public_services_secondary_cidr_block   = var.public_services_secondary_cidr_block
# }

# --------------------------------------------------------------------------------------
# CREATE GKE CLUSTER
# --------------------------------------------------------------------------------------
module "gke_cluster" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id        = var.project
  name              = "${var.cluster_name}-${var.environment}"
  region            = var.region
  network           = var.network_name
  count             = length(module.vpc_network.subnets)
  subnetwork        = module.vpc_network.subnets[count.index].subnet_name
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services
}

# module "gke_cluster" {
#   depends_on = [
#     module.vpc_network
#   ]
#   # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
#   # to a specific version of the modules, such as the following example:
#   # source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-cluster?ref=v0.2.0"
#   source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-cluster?ref=v0.10.0"

#   name = "${var.cluster_name}-${var.environment}"

#   project  = var.project
#   location = var.region

#   # We're deploying the cluster in the 'public' subnetwork to allow outbound internet access
#   # See the network access tier table for full details:
#   # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
#   network                      = module.vpc_network.network
#   subnetwork                   = module.vpc_network.public_subnetwork
#   cluster_secondary_range_name = module.vpc_network.public_subnetwork_secondary_range_name

#   # To make testing easier, we keep the public endpoint available. In production, we highly recommend restricting access to only within the network boundary, requiring your users to use a bastion host or VPN.
#   disable_public_endpoint = "false"

#   # add resource labels to the cluster
#   resource_labels = {
#     environment = var.environment
#   }
# }

# # #--------------------------------------------------------------------------------------
# # # CREATE NODE POOL
# # #-------------------------------------------------------------------------------------
# resource "google_container_node_pool" "node-pool" {
#   # provider = google-beta

#   name       = "${module.gke_cluster.name}-node-pool"
#   cluster    = module.gke_cluster.name
#   location   = var.region
#   node_count = 1

#   autoscaling {
#     min_node_count = var.min_count
#     max_node_count = var.max_count
#   }

#   management {
#     auto_repair  = "true"
#     auto_upgrade = "true"
#   }

#   node_config {
#     machine_type    = "e2-standard-2"
#     service_account = module.gke_service_account.email
#     disk_size_gb    = "30"
#     disk_type       = "pd-standard"
#     preemptible     = false
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring"
#     ]
#   }
# }

# resource "time_sleep" "wait_30_seconds" {
#   depends_on = [module.gke_cluster]
#   create_duration = "30s"
# }

# module "gke_auth" {
#   depends_on           = [time_sleep.wait_30_seconds]
#   source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#   project_id           = var.project_id
#   cluster_name         = module.gke_cluster.name
#   location             = var.region
#   use_private_endpoint = false
# }

# # ---------------------------------------------------------------------------------------------------------------------
# # CREATE A CUSTOM SERVICE ACCOUNT TO USE WITH THE GKE CLUSTER
# # ---------------------------------------------------------------------------------------------------------------------
# module "gke_service_account" {
#   # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
#   # to a specific version of the modules, such as the following example:
#   # source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-service-account?ref=v0.2.0"
#   source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-service-account?ref=v0.10.0"

#   name        = "${var.cluster_service_account_name}-${var.environment}"
#   project     = var.project
#   description = var.cluster_service_account_description
# }

# resource "google_project_iam_member" "deimos-gcp-explore-01" {
#   project = var.project_id
#   role    = "roles/editor"
#   member  = "serviceAccount:gke-cluster-sa-development@deimos-gcp-explore-01-333007.iam.gserviceaccount.com"
# }
