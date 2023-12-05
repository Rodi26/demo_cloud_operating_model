provider "boundary" {
  recovery_kms_hcl = "../../configuration/boundary_enterprise.hcl"
}


resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "IT_Support"
  description              = "IT Support Team"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "project" {
  name             = "QA_Tests"
  description      = "Manage QA machines"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_host_catalog_static" "devops" {
  name        = "DevOps"
  description = "For DevOps usage"
  scope_id    = boundary_scope.project.id
}

resource "boundary_host_static" "postgres" {
  name            = "postgres"
  description     = "Postgres host"
  address         = "127.0.0.1"
  host_catalog_id = boundary_host_catalog_static.devops.id
}

resource "boundary_host_static" "localhost" {
  name            = "localhost"
  description     = "Localhost for testing"
  address         = "localhost"
  host_catalog_id = boundary_host_catalog_static.devops.id
}

resource "boundary_host_set_static" "test-machines" {
  name            = "test-machines"
  description     = "Host set for postgres"
  host_catalog_id = boundary_host_catalog_static.devops.id
  host_ids = [
      boundary_host_static.postgres.id,
      boundary_host_static.localhost.id,
  ]
}

resource "boundary_target" "tests" {
  type                     = "tcp"
  name                     = "tests"
  description              = "Test target"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.test-machines.id
  ]
}

resource "boundary_auth_method" "password" {
  name        = "org_password_auth"
  description = "Password auth method for org"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

resource "boundary_account_password" "test_account" {
  name           = "test_account"
  description    = "Test password account"
  //type           = "password"
  login_name     = "tester01"
  password       = "admin1234"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "tester01" {
  name        = "tester01"
  description = "A test user"
  account_ids = [
     boundary_account_password.test_account.id
  ]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "group01" {
  name        = "My group"
  description = "A test group"
  member_ids  = [boundary_user.tester01.id]
  scope_id    = boundary_scope.org.id
}
/*
resource "boundary_role" "platform-admin" {
  name        = "platform-admin"
  description = "platform-admin"
  principal_ids = [
     boundary_user.platform_admin.id
  ]
  grant_strings = ["id=*;type=*;actions=*"]
  scope_id      = boundary_scope.platform.id
}

resource "boundary_role" "platform-user-ro" {
  name        = "platform-user-ro"
  description = "platform-user-ro"
  principal_ids = [
    boundary_user.sandy.id
  ]
  grant_strings = [
    "id=${boundary_target.postgres_ro.id};actions=*",
    "id=*;type=session;actions=cancel:self,list,read",
    "id=*;type=target;actions=list,read",
    "id=*;type=host-catalog;actions=list,read",
    "id=*;type=host-set;actions=list,read",
    "id=*;type=host;actions=list,read"
  ]
  scope_id = boundary_scope.platform.id
}
*/