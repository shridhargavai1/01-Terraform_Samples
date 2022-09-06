terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.33.0"
    }
  }
}

provider "google" {
  credentials = file("terraformkey.json")
  project = "silent-text-358817"
  zone  = "asia-south1-c"
  region = "asia-south1"
}
// Service account is already created. Hence commented the code.
// resource "google_service_account" "terraformserviceaccountgeneral"  {
//  account_id   = "terraformserviceaccountgeneral"
//  display_name = "terraformserviceaccountgeneral"
// }

resource "google_compute_instance" "terraformvm1" {
  machine_type = "e2-micro"
  name         = "terraform1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }
}