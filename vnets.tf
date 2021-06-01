# VNets configuration for vWAN Hubs

# VNet definitions
resource "azurerm_virtual_network" "vnet-shared" {
  address_space       = ["172.21.0.0/16"]
  location            = var.lab-location
  name                = "vnet-shared"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet-isolated" {
  address_space       = ["172.22.0.0/16"]
  location            = var.lab-location
  name                = "vnet-isolated"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet-1" {
  address_space       = ["172.17.0.0/22"]
  location            = var.lab-location
  name                = "vnet-1"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet-2" {
  address_space       = ["172.17.4.0/22"]
  location            = var.lab-location
  name                = "vnet-2"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet-3" {
  address_space       = ["172.17.8.0/22"]
  location            = var.lab-location
  name                = "vnet-3"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet-4" {
  address_space       = ["172.17.252.0/22"]
  location            = var.lab-location
  name                = "vnet-4"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

# Subnet definitions - this is not essential but may be used in future
# if in larger demo we decide to have VMs or other Azure services that
# requires proper networking, not just VNets
resource "azurerm_subnet" "vnet-1-subnet-1" {
  name                 = "vnet-1-subnet-1"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["172.17.0.0/24"]
}

resource "azurerm_subnet" "vnet-1-subnet-2" {
  name                 = "vnet-1-subnet-2"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["172.17.1.0/24"]
}

resource "azurerm_subnet" "vnet-2-subnet-1" {
  name                 = "vnet-2-subnet-1"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-2.name
  address_prefixes     = ["172.17.4.0/24"]
}

resource "azurerm_subnet" "vnet-2-subnet-2" {
  name                 = "vnet-2-subnet-2"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-2.name
  address_prefixes     = ["172.17.5.0/24"]
}

resource "azurerm_subnet" "vnet-3-subnet-1" {
  name                 = "vnet-3-subnet-1"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-3.name
  address_prefixes     = ["172.17.8.0/24"]
}

resource "azurerm_subnet" "vnet-4-subnet-1" {
  name                 = "vnet-4-subnet-1"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-4.name
  address_prefixes     = ["172.17.252.0/24"]
}

# Create VNET Peering between vnet-3 and vnet-4
resource "azurerm_virtual_network_peering" "peer-vnet-3-to-vnet-4" {
  name = "peer-vnet-3-to-vnet-4"
  remote_virtual_network_id = azurerm_virtual_network.vnet-4.id
  resource_group_name = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-3.name
}

resource "azurerm_virtual_network_peering" "peer-vnet-4-to-vnet-3" {
  name = "peer-vnet-4-to-vnet-3"
  remote_virtual_network_id = azurerm_virtual_network.vnet-3.id
  resource_group_name = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-4.name
}

# Connect VNETs to HUBs
resource "azurerm_virtual_hub_connection" "vnet-2-northeurope-hub" {
  name                      = "vnet-2-northeurope-hub"
  virtual_hub_id            = azurerm_virtual_hub.HUB-NorthEurope.id
  remote_virtual_network_id = azurerm_virtual_network.vnet-2.id
}

resource "azurerm_virtual_hub_connection" "vnet-1-westeurope-hub" {
  name                      = "vnet-1-westeurope-hub"
  remote_virtual_network_id = azurerm_virtual_network.vnet-1.id
  virtual_hub_id            = azurerm_virtual_hub.HUB-WestEurope.id
}

resource "azurerm_virtual_hub_connection" "vnet-3-westeurope-hub" {
  name                      = "vnet-3-westeurope-hub"
  remote_virtual_network_id = azurerm_virtual_network.vnet-3.id
  virtual_hub_id            = azurerm_virtual_hub.HUB-WestEurope.id
}

resource "azurerm_virtual_hub_connection" "vnet-shared-westeurope-hub" {
  name                      = "vnet-shared-westeurope-hub"
  remote_virtual_network_id = azurerm_virtual_network.vnet-shared.id
  virtual_hub_id            = azurerm_virtual_hub.HUB-WestEurope.id
}

resource "azurerm_virtual_hub_connection" "vnet-isolated-westeurope-hub" {
  name                      = "vnet-isolated-westeurope-hub"
  remote_virtual_network_id = azurerm_virtual_network.vnet-isolated.id
  virtual_hub_id            = azurerm_virtual_hub.HUB-WestEurope.id
}

