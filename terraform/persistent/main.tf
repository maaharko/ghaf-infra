# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

provider "azurerm" {
  # https://github.com/hashicorp/terraform-provider-azurerm/issues/24804
  skip_provider_registration = true
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    secret = {
      source = "numtide/secret"
    }
  }
}

################################################################################

terraform {
  # Backend for storing terraform state (see ../state-storage)
  backend "azurerm" {
    # resource_group_name and storage_account_name are set by the callee
    # from command line in terraform init, see terraform-init.sh
    container_name = "ghaf-infra-tfstate-container"
    key            = "ghaf-infra-persistent.tfstate"
  }
}

################################################################################

# Variables
variable "location" {
  type        = string
  default     = "northeurope"
  description = "Azure region into which the resources will be deployed"
}

locals {
  # Raise an error if workspace is 'default',
  # this is a workaround to missing asserts in terraform:
  assert_workspace_not_default = regex(
    (terraform.workspace == "default") ?
  "((Force invalid regex pattern)\n\nERROR: workspace 'default' is not allowed" : "", "")
}

# Resource group
resource "azurerm_resource_group" "persistent" {
  name     = terraform.workspace
  location = var.location
  lifecycle {
    # Fails any plan that requires this resource to be destroyed.
    # This only protects from Terraform accidental client-side destruction.
    prevent_destroy = true
  }
}

# Current signed-in user
data "azurerm_client_config" "current" {}

################################################################################
