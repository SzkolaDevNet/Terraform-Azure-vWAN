# The Azure Virtual WAN (vWAN) configuration.
# It contains one vWAN servie with two hubs.

resource "azurerm_virtual_wan" "vwan-demo" {
  location            = var.lab-location
  name                = "vwan"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_virtual_hub" "HUB-WestEurope" {
  address_prefix      = "10.0.0.0/24"
  location            = "WestEurope"
  name                = "HUB-WestEurope"
  resource_group_name = var.lab-rg
  virtual_wan_id      = azurerm_virtual_wan.vwan-demo.id
  tags                = var.tags
}

resource "azurerm_virtual_hub" "HUB-NorthEurope" {
  address_prefix      = "10.1.0.0/24"
  location            = "NorthEurope"
  name                = "HUB-NorthEurope"
  resource_group_name = var.lab-rg
  virtual_wan_id      = azurerm_virtual_wan.vwan-demo.id
  tags                = var.tags
}

resource "azurerm_vpn_gateway" "VPNGW-HUB-WestEurope" {
  location            = "WestEurope"
  name                = "VPNGW-HUB-WestEurope"
  resource_group_name = var.lab-rg
  virtual_hub_id      = azurerm_virtual_hub.HUB-WestEurope.id
  tags                = var.tags
}