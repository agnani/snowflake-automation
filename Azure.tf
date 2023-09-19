# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      # version = "0.69.0"
      version = "0.58.2"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

resource "azurerm_resource_group" "Azure_snowflake" {
  name     = var.name
  location = var.location
}

resource "azurerm_virtual_network" "Azure_snowflake" {
  name                = "${var.name}_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Azure_snowflake.location
  resource_group_name = azurerm_resource_group.Azure_snowflake.name
}

resource "azurerm_subnet" "Azure_snowflake" {
  name                 = "${var.name}_Subnet01"
  resource_group_name  = azurerm_resource_group.Azure_snowflake.name
  virtual_network_name = azurerm_virtual_network.Azure_snowflake.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "Azure_snowflake" {
  count               = var.use_static_ip == true ? 0 : 1
  name                = "${var.name}-01-pip"
  resource_group_name = azurerm_resource_group.Azure_snowflake.name
  location            = azurerm_resource_group.Azure_snowflake.location
  allocation_method   = "Static"
}

data "azurerm_public_ip" "Azure_snowflake" {
  count               = var.use_static_ip == true ? 1 : 0
  name                = var.VM_public_ip_name
  resource_group_name = var.VM_public_ip_rg
}

resource "azurerm_network_interface" "Azure_snowflake" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.Azure_snowflake.location
  resource_group_name = azurerm_resource_group.Azure_snowflake.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Azure_snowflake.id
    private_ip_address_allocation = "Dynamic" # vars
    public_ip_address_id          = var.use_static_ip == true ? data.azurerm_public_ip.Azure_snowflake[0].id : azurerm_public_ip.Azure_snowflake[0].id
  }
}

resource "azurerm_linux_virtual_machine" "Azure_snowflake" {
  name                            = "${var.name}-Dataiku-01"
  computer_name                   = var.computer_name
  resource_group_name             = azurerm_resource_group.Azure_snowflake.name
  location                        = azurerm_resource_group.Azure_snowflake.location
  size                            = var.VM_machine_size
  disable_password_authentication = "false"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.Azure_snowflake.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size_gb
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.Azure_snowflake.public_ip_address
  }

  provisioner "file" {
    source      = var.data-iq-license
    destination = "/tmp/license.json"
  }

  provisioner "remote-exec" {

    inline = [

      "sudo apt-get update",
      "wget https://cdn.downloads.dataiku.com/public/dss/11.3.2/dataiku-dss-11.3.2.tar.gz",
      "tar xzf dataiku-dss-11.3.2.tar.gz",
      "sudo NEEDRESTART_MODE=a -i '/home/${var.admin_username}/dataiku-dss-11.3.2/scripts/install/install-deps.sh' -yes",
      "dataiku-dss-11.3.2/installer.sh -d DATA_DIR -p 11000 -l /tmp/license.json",
      "DATA_DIR/bin/dss start",
      "sudo '/home/${var.admin_username}/dataiku-dss-11.3.2/scripts/install/install-boot.sh' '/home/${var.admin_username}/DATA_DIR' azureuser"
    ]
  }
  # custom_data = base64encode(file("${path.module}/data-iq.sh"))

}

# data "bash_script" "install_data_iq" {
#   template = file("data-iq.sh")
# }

# output "instance_ip_addr" {
#   value = azurerm_linux_virtual_machine.Azure_snowflake.public_ip
# }
