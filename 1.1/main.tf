provider "yandex" {
  token     = "AQAAAABexI8IAATuwf6cHcyiZk6PnUUuRlQLQKI"
  cloud_id  = "cloud-lyambdazondgmailcom"
  folder_id = "b1g1e417rlclna6nbfk6"
  zone      = "ru-central1-b"

}

terraform {

  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
   backend "s3" {
      endpoint   = "storage.yandexcloud.net"
      bucket     = "nikdiplom"
      region     = "ru-central1"
      key        = "project/terraform.tfstate"
      access_key = "YCAJEBsY6XciSeYVFc85Z_IGn"
      secret_key = "YCPFJNbjLPIH5oDUc5OuZkCnTlmmqo9TMrWwpvGw"

      skip_region_validation      = true
      skip_credentials_validation = true
  }
  }


resource "yandex_vpc_network" "kube_network" {}

resource "yandex_vpc_subnet" "public" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.kube_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  name               = "public"
}

resource "yandex_compute_instance" "kube_control" {
    name               = "kube-control"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 2
        cores  = 2
        core_fraction = 20
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd827b91d99psvq5fjit"

        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.20"
      }
        metadata = {
        username = "ubuntu"
        password = "ubuntu"
        ssh-keys = "ubuntu:${file("pubkey.pem.pub")}"
      }

}

resource "yandex_compute_instance" "worker1" {
    name               = "worker1"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 0.5
        cores  = 2
        core_fraction = 5
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd827b91d99psvq5fjit"

        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.21"
      }
        metadata = {
        username = "ubuntu"
        password = "ubuntu"
        ssh-keys = "ubuntu:${file("pubkey.pem.pub")}"
      }


}

resource "yandex_compute_instance" "worker2" {
    name               = "worker2"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 0.5
        cores  = 2
        core_fraction = 5
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd827b91d99psvq5fjit"

        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.22"
      }
        metadata = {
        username = "ubuntu"
        password = "ubuntu"
        ssh-keys = "ubuntu:${file("pubkey.pem.pub")}"
      }

}

resource "yandex_iam_service_account" "terraform-stage" {
  name        = "terraform-stage"
  description = "service account to manage IG"

}

