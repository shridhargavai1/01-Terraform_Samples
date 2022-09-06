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

project = "stable-liberty-361719"
region      = "us-east1"
zone        = "us-east1-b"
sync_repo   = "https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git"
sync_branch = "master"
policy_dir  = "examples/acm-terraform-blog-part1/config-root"
project_id = "stable-liberty-361719"
cluster_name_suffix = "-pod-dev"
credentials = "terraformkey.json"
tf_zone = "us-east1-b"
zones = [
  "us-east1-b"
]
network = "private-gke-net"
subnetwork = "private-gke-subnet"
ip_range_pods = "pod-ip"
ip_range_services = "service-ip"
compute_engine_service_account = "terraformserviceaccount@stable-liberty-361719.iam.gserviceaccount.com"
master_ip4_cidr = "172.16.0.0/28"
sec_pod_range = "192.168.0.0/18"
sec_service_range = "192.168.64.0/18"
