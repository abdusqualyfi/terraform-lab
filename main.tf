#Provides config details for Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.55.0"
    }
  }
}

#Provides config details for Azure Terraform provider
provider "azurerm" {
  features {}
  use_msi = true
}

#Provides the Resource Group to logically contain resources
resource "azurerm_resource_group" "gen_resource_group" {
  name     = "abdus-terraform"
  location = "eastus"
  tags = {
    environtment = "dev"
    source       = "Terraform"
    owner        = "abdus"
  }
}

#Generate Data Factory resource
resource "azurerm_data_factory" "gen_data_factory" {
  name                = "abdus-data-factory"
  resource_group_name = azurerm_resource_group.gen_resource_group.name
  location            = azurerm_resource_group.gen_resource_group.location
}

#Generate Data Lake Gen 2 resources
resource "azurerm_storage_account" "gen_data_lake_gen2" {
  name                     = "abdusstorage"
  resource_group_name      = azurerm_resource_group.gen_resource_group.name
  location                 = azurerm_resource_group.gen_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "gen_storage_container" {
  name                  = "my-container"
  storage_account_name  = azurerm_storage_account.gen_data_lake_gen2.name
  container_access_type = "private"
}

#Generate Databricks resource
resource "azurerm_databricks_workspace" "gen_databricks" {
  name                = "abdus-databricks-workspace"
  location            = azurerm_resource_group.gen_resource_group.location
  resource_group_name = azurerm_resource_group.gen_resource_group.name
  sku                 = "standard"
}

#Generate SQL DB resources
resource "azurerm_sql_server" "gen_sql_server" {
  name                         = "abdus-sql-server"
  resource_group_name          = azurerm_resource_group.gen_resource_group.name
  location                     = azurerm_resource_group.gen_resource_group.location
  version                      = "12.0"
  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_database" "gen_sql_db" {
  name                             = "my-sql-database"
  resource_group_name              = azurerm_resource_group.gen_resource_group.name
  location                         = azurerm_resource_group.gen_resource_group.location
  server_name                      = azurerm_sql_server.gen_sql_server.name
  edition                          = "Standard"
  requested_service_objective_name = "S0"
}