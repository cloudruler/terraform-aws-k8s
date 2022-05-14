terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.13.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.49"
    }
  }
}