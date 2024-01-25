terraform {
  required_version = ">= 1.5"

  backend "remote" {
    organization = "imjarois"

    workspaces {
      name = "tfprov-issue-780"
    }
  }

  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = ">= 3.5.1"
    }
  }
}

provider "pagerduty" {}
