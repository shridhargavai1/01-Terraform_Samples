/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
# google_client_config and kubernetes provider must be explicitly specified like the following.

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
  credentials = file(var.credentials)
  }

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.tf_zone
  credentials = file(var.credentials)
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

locals {
  cluster_type = "simple-zonal-private"
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork
  project = var.project_id
  region  = var.region
}

module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com"
  ]

  depends_on = [google_compute_network.main]
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "23.0.0"
  project_id              = var.project_id
  name                    = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                = false
  region                  = var.region
  zones                   = var.zones
  network                 = var.network
  subnetwork              = var.subnetwork
  ip_range_pods           = var.ip_range_pods
  ip_range_services       = var.ip_range_services
  create_service_account  = false
  service_account         = var.compute_engine_service_account

  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false /* true for private */
  enable_private_nodes       = false /* true for private */
  master_ipv4_cidr_block     = var.master_ip4_cidr

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = var.tf_zone
      min_count                 = 1
      max_count                 = 3
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 10
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.compute_engine_service_account
      preemptible               = false
      initial_node_count        = 3
    },
  ]

  master_authorized_networks_config = [
    {
      //    cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      cidr_block   = "192.168.0.0/28"
      display_name = "VPC"
    },
  ]


  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "default-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
  depends_on = [module.enabled_google_apis]
}

resource "google_gke_hub_membership" "membership" {
  membership_id = "membership-hub-${module.gke.name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  depends_on = [module.gke]
}

resource "google_gke_hub_feature" "google_gke_hub_feature03" {
  provider   = google-beta
  name     = "configmanagement"
  location = "global"
  depends_on = [google_gke_hub_membership.membership]
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider   = google-beta
  location   = "global"
  feature    = "configmanagement"

  membership = google_gke_hub_membership.membership.membership_id
  configmanagement {
    version = "1.12.2" /* This was 1.8.0 but error :  supported versions are 1.12.0, 1.12.1, 1.12.2 */
    config_sync {
      source_format = "unstructured"
      git {
        sync_repo   = var.sync_repo
        sync_branch = var.sync_branch
        policy_dir  = var.policy_dir
        secret_type = "none"
      }
    }
  }
  depends_on = [
    google_gke_hub_feature.google_gke_hub_feature03
  ]
}
//* -------------------------------------------------------------------------*//

