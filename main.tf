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
      version = ">= 3.0.0"
    }
  }
}

provider "pagerduty" {}

resource "pagerduty_team" "tfprov_issue780_team" {
  name = "tfprov_issue780_team"
}

resource "pagerduty_tag" "issue780" {
  label = "GH-ISSUE-780"
}

resource "pagerduty_tag" "whatever" {
  label = "whatever"
}

resource "pagerduty_tag_assignment" "issue780_team_tag_issue780" {
  tag_id      = pagerduty_tag.issue780.id
  entity_type = "teams"
  entity_id   = pagerduty_team.tfprov_issue780_team.id
}

resource "pagerduty_tag_assignment" "issue780_team_tag_whatever" {
  tag_id      = pagerduty_tag.whatever.id
  entity_type = "teams"
  entity_id   = pagerduty_team.tfprov_issue780_team.id
}
