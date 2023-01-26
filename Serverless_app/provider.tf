
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
  region = "us-east-2"
  # region                   = "us-west-2"
  shared_credentials_files = [("~/.aws/credentials")]
  # shared_credentials_file = "/Users/M ROBLE/.aws/credentials"
  # profile = "default"
  profile = "devop01"
}

# a provider is to interact with the API of your infrastructure


