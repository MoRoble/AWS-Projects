### different ways to setup backends/providers
#### to use external/cloud backend is more secure and reliable 


##### for HashiCorp terraform cloud backend is easy to manage 
terraform {
  cloud {
    organization = "ROBLE-Engineering"

    workspaces {
      name = "arday-backend"
    }
  }
}
# requires to create token and login from the terminal 
# to create token, click your avator and scroll then create new token
# terraform login will be the command to login then paste your token
# terraform cloud login app.terraform.io
# terraform will store token in $HOME/.terraform.d/credentials.tfrc.json


# for S3 backend of our infrastructure
# terraform {
#   backend "s3" {
#     bucket         = "global-terraform.com"
#     key            = "arday/project.tfstate"
#     dynamodb_table = "global-terraform"
#     region         = "eu-north-1"
#     profile        = "devadmin"
#   }
# }
