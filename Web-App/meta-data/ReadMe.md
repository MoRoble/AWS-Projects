## Instance Meta-data explained.

instance metadata is provided at this link http://169.254.169.254/latest/metadata/ which works when executed on a running instance using 'curl or wget' utility.
in addition to that I could be used http://169.254.169.254/metadata/instance-id/ if I want to query specific metadata layer.
Furthermore I can run this `user data` when launch EC2
```
#!/usr/bin/env python

 

import requests

import json

# Converts AWS EC2 instance metadata to a dictionary

def load():

    metaurl = 'http://169.254.169.254/latest'

    # those 3 top subdirectories are not exposed with a final '/'

    metadict = {'dynamic': {}, 'meta-data': {}, 'user-data': {}}

    for subsect in metadict.keys():

        datacrawl('{0}/{1}/'.format(metaurl, subsect), metadict[subsect])

    return metadict

def datacrawl(url, d):

    r = requests.get(url)

    if r.status_code == 404:

        return

    for l in r.text.split('\n'):

        if not l: # "instance-identity/\n" case

            continue

        newurl = '{0}{1}'.format(url, l)

        # a key is detected with a final '/'

        if l.endswith('/'):

            newkey = l.split('/')[-2]

            d[newkey] = {}

            datacrawl(newurl, d[newkey])

        else:

            r = requests.get(newurl)

            if r.status_code != 404:

                try:

                    d[l] = json.loads(r.text)

                except ValueError:

                    d[l] = r.text

            else:

                d[l] = None

if __name__ == '__main__':

    print(json.dumps(load()))

```

### on Terraform

To show the metadata of an instance, we need to deploy an EC2 instance in AWS with an argument then execute terraform plan. The output result will be in JSON file.
`copy` text in file `meta-data` in this repository
Here I will put my main.tf file which will be in Hodan-tf directory

```
# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

# variables.tf

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

```
