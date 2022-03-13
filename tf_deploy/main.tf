terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.53.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~>2.1.0"
    }
  }
}

provider "google" {
  credentials = file(var.credential_file)

  project = "${var.gcp_project}"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_region}-${var.gcp_zone}"
}

# Create a GCS Bucket

resource "google_storage_bucket_access_control" "writer_rule" {
  bucket = google_storage_bucket.pg_backrest_repo.name
  role   = "WRITER"
  entity = "user-idi-pgbackrest@idi-patroni-pgbackrest.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "pg_backrest_repo" {
name     = "${var.gcp_bucket}"
location = "${var.gcp_region}"
force_destroy = true
}



resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "firewall_ssh" {
  name    = "firewall-ssh"
   network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["patroni"]
}

resource "google_compute_firewall" "firewall_internal" {
  name    = "firewall-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","5432","6432","8008","2379","2380"]
  }

  source_tags = ["patroni"]
}


resource "google_compute_instance" "patroni_instance" {
  name         = "${var.node_prefix}${count.index}"
  machine_type = "e2-small"
  
  tags         = ["patroni"]
  count = var.patroni_node_count
    labels = { 
    patroni-node = count.index,
  } 
  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-8"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      
    }
  }

  metadata = {
   ssh-keys = "${var.ssh_user}:${file("${var.HOME}/${var.ssh_key}.pub")}"
 }
}



resource "local_file" "ssh_config" {
  content = templatefile("ssh.tmpl",
    {
     node-ip = google_compute_instance.patroni_instance.*.network_interface.0.access_config.0.nat_ip,
     node-name = google_compute_instance.patroni_instance.*.name
     ssh_user = var.ssh_user
     ssh_key = "${var.HOME}/${var.ssh_key}"
     number_of_nodes = range(var.patroni_node_count)
     node_prefix = var.node_prefix
    }
  )
  filename = "${var.HOME}/${var.ssh_conf}"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("hosts.tmpl",
    {
     node-name = google_compute_instance.patroni_instance.*.name
     number_of_nodes = range(var.patroni_node_count)
     ssh_user = var.ssh_user
     ssh_key = "${var.HOME}/${var.ssh_key}"
    }
  )
  filename = "../ansible/inventory/gcp/hosts"
}

resource "local_file" "ansible_varariables" {
  content = templatefile("tf_variables.yml.tmpl",
    {
     gcp_bucket = google_storage_bucket.pg_backrest_repo.name
    }
  )
  filename = "../ansible/inventory/gcp/group_vars/all/tf_variables.yml"
}
