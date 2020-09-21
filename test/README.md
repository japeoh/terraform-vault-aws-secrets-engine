# Test

## Setup Vault 

```shell script
podman run --rm -d \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=root' \
  --cap-add=IPC_LOCK \
  --name=vault vault
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
```

## Apply

```shell script
terraform init
terraform apply -auto-approve
```

Run the commands in the Terraform output to validate

## Rotate Credentials

```shell script
terraform taint module.vault_aws_secret_engine.aws_iam_access_key.aws_secret_engine_user
terraform apply -auto-approve
```

Run the commands in the Terraform output to validate


## Destroy

```shell script
curl \
  --header "X-Vault-Token: "$VAULT_TOKEN"" \
  --request PUT \
  $VAULT_ADDR/v1/sys/leases/revoke-force/aws/creds
terraform destroy -force
podman stop vault
```

## Additional AWS Permissions to Create Test Roles and Groups

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateRolesForTesting",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::XXXXXXXXXXXX:role/vault-test/*"
    },
    {
      "Sid": "CreateGroupsForTesting",
      "Effect": "Allow",
      "Action": [
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:GetGroup"
      ],
      "Resource": "arn:aws:iam::XXXXXXXXXXXX:group/vault-test/*"
    }
  ]
}
```
