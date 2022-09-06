project_id = "silent-text-358817"
cluster_name_suffix = "-pod-dev"
credentials = "terraformkey.json"
region = "us-east1"
tf_zone = "us-east1-b"
zones = [
  "us-east1-b"
]
network = "private-gke-net"
subnetwork = "private-gke-subnet"
ip_range_pods = "pod-ip"
ip_range_services = "service-ip"
compute_engine_service_account = "terraformserviceaccountgeneral@silent-text-358817.iam.gserviceaccount.com"

