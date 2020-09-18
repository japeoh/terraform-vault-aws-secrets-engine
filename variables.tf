variable path {
  description = "The unique path this backend should be mounted at"
  default     = "aws"
}
variable description {
  description = "A human-friendly description for this backend"
  default     = "AWS Secret Engine"
}
variable region {
  description = "The AWS region for API calls"
  default     = "eu-west-2"
}
variable default_lease_ttl_seconds {
  description = "The default TTL for credentials issued by this backend"
  default     = 60
}
variable max_lease_ttl_seconds {
  description = "The maximum TTL that can be requested for credentials issued by this backend"
  default     = 3600
}
variable assumed_roles {
  description = "List of assumed_role type roles to be configured"
  type = list(object({
    name            = string
    role_arns       = list(string)
    default_sts_ttl = number
    max_sts_ttl     = number
  }))
}
variable iam_users {
  description = "List of iam_user type roles to be configured"
  type = list(object({
    name       = string
    iam_groups = list(string)
  }))
}
variable tags {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
