As part of our AWS Projects here I am going to post a project that I have done for a client to make sure they have got a backup static website for the cases of their current website outage.

- [One-Click DNS Deployment](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://roble-files.s3.amazonaws.com/Hodan-Project/R53-failover.yml&stackName=HDN-Domain-Host)

Following architecture explains how our web server is being accessed in either public or private users

![Route 53 - Web Server](https://github.com/MoRoble/AWS-Projects/blob/051de45fc64f997be4ef0966294df1a5475ef904/Amazon-Route53/Web-Server%20-%20R53.jpg)


Using split-horizon technique we are able provision web server that is partially being accessed by external users while internal users will be presented intranet.
