# Example below heavily lifted from:
# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/host_catalog_plugin

resource "boundary_scope" "org" {
  name                     = "demo_organization"
  description              = "Used to demo Boundary capabilities."
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  name                   = "demo_dynamic_host_catalog"
  description            = "Used to demo Boundary dynamic host catalog capabilities."
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog_plugin" "aws_ec2" {
  name            = "AWS Sandbox"
  description     = "Host catalog in AWS Sandbox"
  scope_id        = boundary_scope.project.id
  plugin_name     = "aws"
  attributes_json = jsonencode({ "region" = data.aws_region.current.name })
  secrets_json = jsonencode({
    "access_key_id"     = aws_iam_access_key.boundary_dynamic_host_catalog.id
    "secret_access_key" = aws_iam_access_key.boundary_dynamic_host_catalog.secret
  })
  depends_on = [time_sleep.boundary_dynamic_host_catalog_user_ready]
}

resource "boundary_host_set_plugin" "aws_ec2_production" {
  name            = "production"
  description     = "Host set for AWS EC2 instances"
  host_catalog_id = boundary_host_catalog_plugin.aws_ec2.id
  //type            = "dynamic"
  attributes_json     = jsonencode({ "filters": ["tag:application=production"] })
}

resource "boundary_host_set_plugin" "aws_ec2_development" {
  name            = "developpment"
  description     = "Host set for AWS EC2 instances"
  host_catalog_id = boundary_host_catalog_plugin.aws_ec2.id
  //type            = "dynamic"
  attributes_json     = jsonencode({ "filters": ["tag:application=dev"] })
}

resource "boundary_host_set_plugin" "aws_ec2_database" {
  name            = "database"
  description     = "Host set for AWS EC2 instances"
  host_catalog_id = boundary_host_catalog_plugin.aws_ec2.id
  //type            = "dynamic"
  attributes_json     = jsonencode({ "filters": ["tag:application=database"] })
}