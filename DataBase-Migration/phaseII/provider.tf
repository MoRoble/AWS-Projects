
##### for local providers use
#############################
# to provide configuration that terraform need to know
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Provider block, provides the information need to access AWS specificly
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "devenv01"
}



