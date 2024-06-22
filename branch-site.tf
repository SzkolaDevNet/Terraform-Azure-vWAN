# This configuration deploys the non-essential part of the vWAN
# I use it to simulate the branch site for the lab topology
# It is just a VNET with VPN Gateway and VPB connection to vWAN

locals {
  shared-key = "4-v3ry-53cr37-k3y"
  branch_asn = 65400
}

# Public IP for VPN Gateway (branch)
resource "azurerm_public_ip" "vnet-branch-vpngw-publicip" {
  name                 = "vnet-branch-vpngw-publicip"
  location             = var.lab-location
  resource_group_name  = var.lab-rg
  sku                  = "Standard"
  sku_tier             = "Regional"
  allocation_method    = "Static"
  ddos_protection_mode = "Disabled"
  tags                 = var.tags
}

# Branch VNet
resource "azurerm_virtual_network" "vnet-branch-1" {
  address_space = ["10.252.252.0/22"]
  location            = var.lab-location
  name                = "vnet-branch-1"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_subnet" "vnet-branch-1-subnet-1" {
  name                 = "net-branch-1-subnet-1"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-branch-1.name
  address_prefixes = ["10.252.252.0/24"]
}

resource "azurerm_subnet" "vnet-branch-1-subnet-2" {
  name                 = "net-branch-1-subnet-2"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-branch-1.name
  address_prefixes = ["10.252.253.0/24"]
}

# Gateway subnet for VPN Gateway
resource "azurerm_subnet" "vnet-branch-1-subnet-gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-branch-1.name
  address_prefixes = ["10.252.255.0/24"]
}

# VPN Gateway - we are using the small one to not generate cost. The BGP must be active
resource "azurerm_virtual_network_gateway" "vnet-branch-1-vpngw" {
  location            = var.lab-location
  name                = "vnet-branch-1-vpngw"
  resource_group_name = var.lab-rg
  vpn_type            = "RouteBased"
  generation          = "Generation1"
  sku                 = "VpnGw1"
  type                = "Vpn"
  enable_bgp          = true
  active_active       = false
  bgp_settings {
    asn = local.branch_asn
  }
  ip_configuration {
    public_ip_address_id = azurerm_public_ip.vnet-branch-vpngw-publicip.id
    subnet_id            = azurerm_subnet.vnet-branch-1-subnet-gw.id
  }
  tags = var.tags
}

# Local network gateway to define the vWAN Hub side
resource "azurerm_local_network_gateway" "vpn-to-vwan-hub" {
  address_space = [
    "${tolist(azurerm_vpn_gateway.VPNGW-HUB-WestEurope.bgp_settings[0].instance_0_bgp_peering_address[0].tunnel_ips)[0]}/32"
  ]
  gateway_address     = tolist(azurerm_vpn_gateway.VPNGW-HUB-WestEurope.bgp_settings[0].instance_0_bgp_peering_address[0].tunnel_ips)[1]
  location            = var.lab-location
  name                = "vpn-to-vwan-hub"
  resource_group_name = var.lab-rg
  bgp_settings {
    asn                 = azurerm_vpn_gateway.VPNGW-HUB-WestEurope.bgp_settings[0].asn
    bgp_peering_address = tolist(azurerm_vpn_gateway.VPNGW-HUB-WestEurope.bgp_settings[0].instance_0_bgp_peering_address[0].tunnel_ips)[0]
  }
  tags = var.tags
}

# VPN Connection
resource "azurerm_virtual_network_gateway_connection" "branch-to-hub-vpn" {
  name                = "branch-to-hub-vpn"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  type       = "IPsec"
  enable_bgp = true

  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet-branch-1-vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.vpn-to-vwan-hub.id

  shared_key = local.shared-key
  tags       = var.tags
}

#################
# The vWAN part of the connection
#################

# Site definition (of branch-1)
resource "azurerm_vpn_site" "branch-1-vpn" {
  name                = "branch-1-site"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  virtual_wan_id      = azurerm_virtual_wan.vwan-demo.id

  link {
    name       = "VPN1"
    ip_address = azurerm_public_ip.vnet-branch-vpngw-publicip.ip_address
    bgp {
      asn             = azurerm_virtual_network_gateway.vnet-branch-1-vpngw.bgp_settings[0].asn
      peering_address = azurerm_virtual_network_gateway.vnet-branch-1-vpngw.bgp_settings[0].peering_addresses[0].default_addresses[0]
    }
  }
}

# Then we connect the site to vWAN hub
resource "azurerm_vpn_gateway_connection" "vpn-vwan-to-branch-1-connection" {
  name               = "vpn-vwan-to-branch-1-connection"
  vpn_gateway_id     = azurerm_vpn_gateway.VPNGW-HUB-WestEurope.id
  remote_vpn_site_id = azurerm_vpn_site.branch-1-vpn.id

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.branch-1-vpn.link[0].id
    shared_key       = local.shared-key
    bgp_enabled      = true
  }
}
