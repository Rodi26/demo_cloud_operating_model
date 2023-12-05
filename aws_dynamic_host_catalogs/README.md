# Demo scenario

The original repo [https://github.com/hashicorp/hc-sec-demos/tree/main/demos/boundary/aws_dynamic_host_catalogs](https://github.com/hashicorp/hc-sec-demos/tree/main/demos/boundary/aws_dynamic_host_catalogs) has been used as a technical asset. 

The creation of 3 dynamic has been added dev, production & database. 

# First steps of the demo :
1/ Do a Terraform apply to create the boundary objects.
2/ Show the boundary objects in the UI

# Second steps : 
1/ Connect to the EC2 interface to show there is no ec2 instances running
2/ navidate to the /host directory and show the code
3/ Do a terraform apply and show the the host have been automatically added to your host catalogs with the right tags.


The doc below s from the original repo. 
# Set up a demo of Boundary AWS Dynamic Host Catalogs

Boundary Dynamic Host catalogs allow for Boundary to automatically discover hosts in your cloud environment. This playbook walks you through setting up Boundary to discover hosts in AWS using your Doormat-provided [Individual Sandbox Account](https://docs.prod.secops.hashicorp.services/cloud_service_providers/aws/individual_sbx_accounts/).

> :warning: The Terraform state that results from deploying this Terraform contains IAM user access keys. **Do not check the Terraform state files into Github or another VCS!**

## Prerequisites
- You must have a Doormat-provided [Individual Sandbox Account](https://docs.prod.secops.hashicorp.services/cloud_service_providers/aws/individual_sbx_accounts/).
- A Boundary controller with a global boundary in place (default in HCP; at time of writing, this is not necessarily the
case if you are running this on-prem or locally).

## Provided Terraform

> :warning: The Terraform state that results from deploying this Terraform contains IAM user access keys. **Do not check the Terraform state files into Github or another VCS!**

The provided Terraform is specifically targeted to providing an example of getting the dynamic catalog configured. It
does not provide a full, in-depth configuration including tags, EC2 instances, etc. To that end, to get a complete demo
up and running, you will need to add Terraform specific to your demo.

## FAQ
### Why can this demo only be run in Individual Sandbox accounts?
IAM user credentials increase the risk of credential leakage and unauthorized access to our AWS environment. Given that IAM users are required for this demo, we want to limit the blast radius in the event that their corresponding credentials are leaked.

There are two ways we are doing this:

1. Limit the permissions on the IAM users.

The permissions policy attached to these IAM users is quite complicated. Essentially, the IAM users are permitted to perform _only_ the actions necessary for this demo. In the event that keys are leaked, the keys are very limited in what they can do. A malicious actor would not be able to escalate privileges or spin up/modify resources (not related to this demo) in our AWS environment.

2. Limit this demo to Individual AWS Sandbox Accounts.

This contains the blast radius of leaked credentials to an environment that is completely isolated and limited to a single user. It also gives us ownership attribution so that Security can contact the account owner in the event that keys are leaked.
