provider "aws" {
  version = "3.0.0"
}

# This provider is for resources that must be created in the us-east-1 region,
# such as ACM certificates for CloudFront, Route 53 query logging, etc.
provider "aws" {
  version = "3.0.0"
  region  = "us-east-1"
  alias   = "use1"
}

# The S3 backend config is given on the command line.
terraform {
  backend "remote" {
    organization = "sveniutest1"

    workspaces {
      name = "itcfy-infra"
    }
  }
}
