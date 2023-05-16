#Provides config details for Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.52.0"
    }
  }
}

#Provides config details for Azure Terraform provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "gen_resource_group" {
  name = "tf-lab"
}

#Generate Data Factory resource
resource "azurerm_data_factory" "gen_data_factory" {
  name                = "ac-data-factory"
  resource_group_name = data.azurerm_resource_group.gen_resource_group.name
  location            = data.azurerm_resource_group.gen_resource_group.location
}

#Generate Data Lake Gen 2 resources
resource "azurerm_storage_account" "gen_data_lake_gen2" {
  name                     = "acstorage"
  resource_group_name      = data.azurerm_resource_group.gen_resource_group.name
  location                 = data.azurerm_resource_group.gen_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "gen_storage_container" {
  name                  = "ac-container"
  storage_account_name  = azurerm_storage_account.gen_data_lake_gen2.name
  container_access_type = "private"
}

#Generate Databricks resource
resource "azurerm_databricks_workspace" "gen_databricks" {
  name                = "ac-databricks-workspace"
  location            = data.azurerm_resource_group.gen_resource_group.location
  resource_group_name = data.azurerm_resource_group.gen_resource_group.name
  sku                 = "standard"
}

#Generate SQL DB resources
resource "azurerm_sql_server" "gen_sql_server" {
  name                         = "ac-sql-server"
  resource_group_name          = data.azurerm_resource_group.gen_resource_group.name
  location                     = data.azurerm_resource_group.gen_resource_group.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Y0unWkow$22"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_database" "gen_sql_db" {
  name                             = "ac-sql-database"
  resource_group_name              = data.azurerm_resource_group.gen_resource_group.name
  location                         = data.azurerm_resource_group.gen_resource_group.location
  server_name                      = azurerm_sql_server.gen_sql_server.name
  edition                          = "Standard"
  requested_service_objective_name = "S0"
}