#Provides config details for Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.52.0"
    }
  }
}

locals {
  prefix = "frax"
}

#Provides config details for Azure Terraform provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription-id
  tenant_id       = var.spn-tenant-id
  client_id       = var.spn-client-id
  client_secret   = var.spn-client-secret
}

data "azurerm_resource_group" "gen_resource_group" {
  name = "tf-lab"
}

output "id" {
  value = data.azurerm_resource_group.gen_resource_group.id
}

#Generate Data Factory resource
resource "azurerm_data_factory" "gen_data_factory" {
  name                = "${local.prefix}-data-factory"
  resource_group_name = data.azurerm_resource_group.gen_resource_group.name
  location            = data.azurerm_resource_group.gen_resource_group.location
}

#Generate Data Lake Gen 2 resources
resource "azurerm_storage_account" "gen_data_lake_gen2" {
  name                     = "${local.prefix}storage"
  resource_group_name      = data.azurerm_resource_group.gen_resource_group.name
  location                 = data.azurerm_resource_group.gen_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "gen_storage_container" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.gen_data_lake_gen2.name
  container_access_type = "private"
}

#Generate Databricks resource
resource "azurerm_databricks_workspace" "gen_databricks" {
  name                        = "${local.prefix}-dbswrkspc"
  location                    = data.azurerm_resource_group.gen_resource_group.location
  resource_group_name         = data.azurerm_resource_group.gen_resource_group.name
  managed_resource_group_name = "${local.prefix}-dbs-managed-rg"
  sku                         = "standard"
}

#Generate SQL DB resources
resource "azurerm_mssql_server" "gen_sql_server" {
  name                         = "${local.prefix}-sql-server"
  resource_group_name          = data.azurerm_resource_group.gen_resource_group.name
  location                     = data.azurerm_resource_group.gen_resource_group.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Y0unWkow$22"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_mssql_database" "gen_sql_db" {
  name           = "${local.prefix}-sqldb"
  server_id      = azurerm_mssql_server.gen_sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = true
}
