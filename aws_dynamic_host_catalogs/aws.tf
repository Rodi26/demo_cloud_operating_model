data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

# Create the user to be used in Boundary for dynamic host discovery. Then attach the policy to the user.
resource "aws_iam_user" "boundary_dynamic_host_catalog" {
  name                 = "demo-${local.my_email}-bdhc"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy_attachment" "boundary_dynamic_host_catalog" {
  user       = aws_iam_user.boundary_dynamic_host_catalog.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

# Generate some secrets to pass in to the Boundary configuration.
# WARNING: These secrets are not encrypted in the state file. Ensure that you do not commit your state file!
resource "aws_iam_access_key" "boundary_dynamic_host_catalog" {
  user = aws_iam_user.boundary_dynamic_host_catalog.name

  depends_on = [aws_iam_user_policy_attachment.boundary_dynamic_host_catalog]
}

# AWS is eventually-consistent when creating IAM Users. Introduce a wait
# before handing credentails off to boundary.
resource "time_sleep" "boundary_dynamic_host_catalog_user_ready" {
  create_duration = "10s"

  depends_on = [aws_iam_access_key.boundary_dynamic_host_catalog]
}