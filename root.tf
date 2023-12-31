terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "mckey" {
  name       = "minecraft_key"
  public_key = file("mckey.pub")
}

resource "hcloud_volume_attachment" "mcvolattach" {
  volume_id = hcloud_volume.mcworld.id
  server_id = hcloud_server.minecraft.id
  automount = true
}

resource "hcloud_server" "minecraft" {
  name        = "Minecraft"
  server_type = "cx21"
  image       = "docker-ce"
  labels = {
    minecraft = 1
  }
  location = "nbg1"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = [
    hcloud_ssh_key.mckey.name,
  ]
}

resource "hcloud_volume" "mcworld" {
  name              = "MC-world"
  size              = 10
  delete_protection = true
  server_id         = hcloud_server.minecraft.id
  automount         = true
  format            = "ext4"
  labels = {
    minecraft = 1
  }
}
provider "docker" {
  host     = "ssh://root@${hcloud_server.minecraft.ipv4_address}"
  ssh_opts = ["-i", "./mckey"]
}

# Pulls the image
resource "docker_image" "mc_docker" {
  name = "itzg/minecraft-server"
}

# Create a container
resource "docker_container" "mc_srv_1" {
  image      = docker_image.mc_docker.image_id
  name       = "mc_server_1"
  tty        = true
  stdin_open = true
  ports {
    internal = 25565
    external = 25565
  }
  env = ["EULA=TRUE"]
  volumes {
    container_path = "/data"
    host_path      = "/mnt/HC_Volume_${hcloud_volume.mcworld.id}"
  }
}

