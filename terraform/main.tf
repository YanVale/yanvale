erraform {
required_version = ">= 0.12"
  backend "azurerm" {
     storage_account_name   = "terraformst"
     container_name         = "terraformlocal"
     key                    = "key1"
     access_key             = "string"
}
} 
provider "azurerm" {
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "local" {
  name     = "resourcegroup-desafio-${random_integer.ri.result}"
  location = "brazilsouth"


}

resource "azurerm_virtual_network" "network1" {
  name                = "desafio-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
}


resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.local.name
  virtual_network_name = azurerm_virtual_network.network1.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_network_interface" "main" {
  name                = "nic1"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name

  ip_configuration {
    name                          = "nic1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}




resource "azurerm_virtual_machine" "vm1" {
  name                  = "vm1"
  location              = azurerm_resource_group.local.location
  resource_group_name   = azurerm_resource_group.local.name
  network_interface_ids = [azurerm_network_interface.local.id]
  vm_size               = "Standard_DS1_v2"

  
  delete_os_disk_on_termination = true



  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "desafiovm1"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "development"
  }
}



resource "azurerm_virtual_machine" "vm2" {
  name                  = "vm2"
  location              = azurerm_resource_group.local.location
  resource_group_name   = azurerm_resource_group.local.name
  network_interface_ids = [azurerm_network_interface.local.id]
  vm_size               = "Standard_DS1_v2"

  
  delete_os_disk_on_termination = true

  

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "desafiovm2"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "development"
  }
}

resource "azurerm_cosmosdb_account" "local" {
  name                = "cosmos-desafio-tf-local"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "EnableServerless"
 }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "EnableMongo"
 }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level = "Session"
  }



  geo_location {
    location = azurerm_resource_group.local.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_mongo_database" "local" {
  name                = "monogodb-desafio"
  resource_group_name = azurerm_cosmosdb_account.local.resource_group_name
  account_name        = azurerm_cosmosdb_account.local.name
}



output "cosmosdb_connection_string" {
    value = azurerm_cosmosdb_account.local.connection_strings
    sensitive = true
}


output "cosmosdb_connection_primary_key" {
    value = azurerm_cosmosdb_account.local.primary_key
    sensitive = true
}


