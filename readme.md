# Hetzner Cloud Automatic Minecraft server

This project tries to provide a extremely simple way to run a public minecraft server on Hetzner Cloud using Terraform.

## Usage:

Follow these steps:

* Download Terraform from https://developer.hashicorp.com/terraform/install and place the executeable in this
  directory (or place it in your PATH).
* Create a Account for Hetzner Cloud at https://accounts.hetzner.com/signUp
* Create a New Project in the Hetzner Cloud Ui (McServer)
* In this project go to Security/API Token and create a new Token called 'Terraform' with Read&Write permissions.
* Create a file named 'terraform.tfvars' with the content:

> hcloud_token = "\*\*YOUR GENERATED API TOKEN\*\*"

* in the Project directory run

> ssh-keygen -f mckey

to generate e new SSH key which can later be used to directly access your server.

> terraform init

Open https://dns.hetzner.com/, go to the zone you want to control and import the zone into terraform like this:

> terraform import hetznerdns_zone.zone1 #id-from-url#

Finally, Start the server with:

> terraform apply

To get the Ipaddress of the server run
> terraform state show hcloud_server.minecraft

Minecraft server data is saved in an additional volume, which allows the server to be shut down/deleted and recreated
without losing the minecraft world.