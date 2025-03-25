# Hetzner Cloud Automatic Minecraft Server

This project provides a simplified way to deploy a public Minecraft server on Hetzner Cloud using Terraform/OpenTofu.

## Prerequisites

Before you begin, ensure you have the following:

* **OpenTofu:** Download OpenTofu
  from [https://opentofu.org/docs/intro/install/](https://opentofu.org/docs/intro/install/) and place the executable in
  the project directory or add it to your system's PATH.
* **Hetzner Cloud Account:** Create an account
  at [https://accounts.hetzner.com/signUp](https://accounts.hetzner.com/signUp).

## Setup

1. **Create a Hetzner Cloud Project:** In the Hetzner Cloud UI, create a new project (e.g., "McServer").
2. **Generate an API Token:** Within the project, navigate to Security/API Tokens and create a new token named "
   OpenTofu" with read and write permissions.
3. **Create `terraform.tfvars`:** Create a file named `terraform.tfvars` in the project directory with the following
   content, replacing `**YOUR GENERATED API TOKEN**` with your actual token:

    ```terraform
    hcloud_token = "**YOUR GENERATED API TOKEN**"
    ```

4. **Generate SSH Key:** Generate a new SSH key for server access:

    ```shell
    ssh-keygen -f mckey
    ```

5. **Import DNS Zone (Optional):** If you want to manage DNS records, import your Hetzner DNS zone using OpenTofu.
   Navigate to https://dns.hetzner.com/, select the zone you want to control, and import it using a command like this (
   replace zone1 and the URL fragment with your zone's information):
    ```shell
    tofu import hetznerdns_zone.zone1 #id-from-url#
    ```
6. **Initialize Terraform:** Initialize the Terraform configuration:
    ```shell
    tofu init
    ```

7. **Apply Configuration:** Deploy the Minecraft server:
    ```shell
    tofu apply
    ```

### Accessing Your Server ###

To retrieve the server's IP address, use the following command:
    ```shell
    tofu state show hcloud_server.minecraft
    ```

### Data Persistence ###

Minecraft server data is stored on a separate volume, ensuring that your world persists even if the server is shut down
or deleted and recreated.