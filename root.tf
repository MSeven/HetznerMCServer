terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49.1"
    }
    hetznerdns = {
      source  = "germanbrew/hetznerdns"
      version = "~> 3.3.3"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}
variable "hdns_token" {
  sensitive = true
}

variable "hdns_domain" {
  sensitive = false
}

provider "hcloud" {
  token = var.hcloud_token
}
provider "hetznerdns" {
  apitoken = var.hdns_token
}

resource "hcloud_ssh_key" "mckey" {
  name       = "minecraft_key"
  public_key = file("mckey.pub")
}

resource "hcloud_volume" "mcworld" {
  name              = "MC-world"
  size              = 10
  delete_protection = true
  automount         = true
  format            = "ext4"
  labels = {
    minecraft = 1
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "hetznerdns_zone" "zone1" {
  name = var.hdns_domain
  ttl  = 300
}

data "template_file" "cloudinit" {
  template = file("cloud-init.yml")

  vars = {
    docker-compose = base64gzip(file("docker-compose.yml"))
    volume_path    = "/dev/sdb"
  }
}

data "cloudinit_config" "foobar" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = file("cloud-init.yml")
  }
}

resource "hcloud_volume_attachment" "mcvolattach" {
  volume_id = hcloud_volume.mcworld.id
  server_id = hcloud_server.minecraft.id
  automount = true
}

resource "hcloud_server" "minecraft" {
  name        = "Minecraft"
  server_type = "cx32"
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
  user_data = data.template_file.cloudinit.rendered
}

resource "hetznerdns_record" "minecraft" {
  zone_id = hetznerdns_zone.zone1.id
  name    = "minecraft"
  value   = hcloud_server.minecraft.ipv4_address
  type    = "A"
  ttl     = 60
}

resource "hetznerdns_record" "minecraft_ip6" {
  zone_id = hetznerdns_zone.zone1.id
  name    = "minecraft"
  value   = hcloud_server.minecraft.ipv6_address
  type    = "AAAA"
  ttl     = 60
}
