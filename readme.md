# Hetzner Cloud Automatic Minecraft server

This project tries to provide a extremely simple way to run a public minecraft server on Hetzner Cloud using Terraform.



## Usage:

Follow these steps:

* Download Terraform from https://developer.hashicorp.com/terraform/install and place the executeable in this directory (or place it in your PATH).
* Create a Account for Hetzner Cloud at https://accounts.hetzner.com/signUp
* Create a New Project in the Hetzneer Cloud Ui (McServer)
* In this project go to Security/API Token and create a new Token called 'Terraform' with Read&Write permissions.
* Create a file named 'terraform.tfvars' with the content: 
> hcloud_token = "\*\*YOUR GENERATED API TOKEN\*\*"
* in the Project directory run 
> ssh-keygen -f mckey

to generate e new SSH key which can later be used to directly access your server.

> terraform init

> terraform apply -target=hcloud_server.minecraft

> terraform apply

To get the Ipaddress of the server run
> terraform state show hcloud_server.minecraft


Minecraft server sata is saved in an additional volume, which allows the server to be shut down/deleted (to save money) and recreated without losing the minecraft world. Note that this volume itself will incur a (minimal) cost over time.