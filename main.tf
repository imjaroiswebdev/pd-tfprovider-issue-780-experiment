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

resource "pagerduty_tag_assignment" "tfprov_issue780_team_tag_issue780" {
  tag_id      = pagerduty_tag.issue780.id
  entity_type = "teams"
  entity_id   = pagerduty_team.tfprov_issue780_team.id
}

resource "pagerduty_tag_assignment" "tfprov_issue780_team_tag_whatever" {
  tag_id      = pagerduty_tag.whatever.id
  entity_type = "teams"
  entity_id   = pagerduty_team.tfprov_issue780_team.id
}

locals {
  team = "Test Team"
  members = [
    "bogus1@pagerduty.com",
    "bogus2@pagerduty.com",
    "bogus3@pagerduty.com",
    "bogus4@pagerduty.com",
    "bogus5@pagerduty.com",
  ]
  start = "2023-11-27T14:30:00-07:00"
  manager = "bogus1@pagerduty.com"
}

resource "pagerduty_team" "default" {
  name = local.team
}

data "pagerduty_user" "team" {
  for_each = toset(local.members)
  email    = each.key
}

data "pagerduty_user" "manager" {
  email = local.manager
}

resource "pagerduty_schedule" "default" {
  name      = "${local.team} schedule"
  time_zone = "America/Los_Angeles"

  layer {
    name                         = "${local.team} Ops Leads"
    start                        = local.start
    rotation_virtual_start       = local.start
    rotation_turn_length_seconds = 60 * 60 * 24 * 7
    users                        = [for member in local.members : data.pagerduty_user.team[member].id]
  }
  teams = [pagerduty_team.default.id]
}

resource "pagerduty_escalation_policy" "default" {
  name  = "${local.team} Escalation Policy"
  teams = [pagerduty_team.default.id]

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.default.id
    }
  }
  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = data.pagerduty_user.manager.id
    }
  }
}
