# terraform-vault-aws-secrets-engine

This module takes an opinionated view of configuring the 
[Vault AWS Secrets Engine](https://www.vaultproject.io/docs/secrets/aws).

It assumes the following.

*   For `iam_user` type credentials, the AWS permissions will be provided by IAM Groups that the dynamic IAM User will
be added to.
*   For `assumed_role` type credentials, the AWS permissions will be provided by simply assuming roles.

This module configures both AWS IAM and the Vault AWS Secrets Engine.

It also configures a Vault Policy for each role created in Vault that allows credentials to be generated.

:warning: This module will store AWS Credentials in your state file :warning:

See the Terraform [Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs) documentation to
understand this and if you decide to use this module take appropriate action to secure your state file.

## Variables

| Name                      | Description |
|---------------------------|---|
| path                      | The path to mount the AWS Secrets Engine in Vault
| description               | A description for the mount
| region                    | The region to make AWS API calls
| default_lease_ttl_seconds | The default lease ttl for the mount
| max_lease_ttl_seconds     | The max lease ttl for the mount
| assumed_roles             | A list of assumed role configurations, documented below
| iam_users                 | A list of iam user configurations, documented below
| tags                      | Tags to apply to the AWS resources created that support tagging

### IAM User Configuration

| Name       | Description |
|------------|---|
| name       | The name of the Vault role to create
| iam_groups | A List of IAM Groups that the dynamic IAM User should be added to 

### Assumed Role Configuration

| Name            | Description |
|-----------------|---|
| name            | The name of the Vault role to create
| role_arns       | A List of IAM Roles that can be assumed by this Vault role
| default_sts_ttl | The default TTL for credentials
| max_sts_ttl     | The max allowed TTL for credentials 

## Output

The module returns a map that, for each Vault role, provides details of the path to generate credentials and the policy
that allows credentials to be generated e.g.

```hcl-terraform
vault_roles = {
  "test1" = {
    "path" = "aws/creds/test1"
    "policy" = "aws/test1"
  }
  "test2" = {
    "path" = "aws/creds/test2"
    "policy" = "aws/test2"
  }
  "test3" = {
    "path" = "aws/creds/test3"
    "policy" = "aws/test3"
  }
  "test4" = {
    "path" = "aws/creds/test4"
    "policy" = "aws/test4"
  }
  "test5" = {
    "path" = "aws/creds/test5"
    "policy" = "aws/test5"
  }
}
```

## AWS IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManageUserForAwsSecretsEngine",
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteLoginProfile",
        "iam:DeleteUser",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListMFADevices",
        "iam:ListSSHPublicKeys",
        "iam:ListSigningCertificates"
      ],
      "Resource": "arn:aws:iam::XXXXXXXXXXXX:user/vault/aws-secrets-engine-*"
    },
    {
      "Sid": "ManagePoliciesForAwsSecretsEngine",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions"
      ],
      "Resource": "arn:aws:iam::XXXXXXXXXXXX:policy/vault/aws-secrets-engine-*"
    },
    {
      "Sid": "ListVirtualMFADevices",
      "Effect": "Allow",
      "Action": "iam:ListVirtualMFADevices",
      "Resource": "*"
    }
  ]
}
```