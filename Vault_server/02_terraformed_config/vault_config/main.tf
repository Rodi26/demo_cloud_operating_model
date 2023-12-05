
variable "lob_namespaces" {
  default = [
    "education",
    "engineering",
    "hr"
  ]
}

variable "team_namespaces" {
  default = [
    "team1",
    "team2",
    "team3"
  ]
}

# Create Top Level namespaces (Lines of Business)

locals {
  lob  = toset(var.lob_namespaces)
  team = toset(var.team_namespaces)
}

resource "vault_namespace" "lobs" {
  for_each = local.lob
  path     = each.key
}

# Create Teams for each LOB

resource "vault_namespace" "lob_education" {
  for_each  = local.team
  namespace = vault_namespace.lobs["education"].path
  path      = "edu_${each.key}"
}

resource "vault_namespace" "lob_engineering" {
  for_each  = local.team
  namespace = vault_namespace.lobs["engineering"].path
  path      = "eng_${each.key}"
}

resource "vault_namespace" "lob_hr" {
  for_each  = local.team
  namespace = vault_namespace.lobs["hr"].path
  path      = "hr_${each.key}"
}