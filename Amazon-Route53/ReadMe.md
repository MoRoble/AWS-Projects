## Amazon Route-53

As part of our AWS Projects here's another usefull project where I will go through the need for Hodan School to route their users accessing public or private resources in a reliable and cost effective way. I have suggested to use Amazon cloud solutions in general and Amazon Route-53 to manage our domains which benefits a fast, flexibility, security, scalability and hybrid cloud.

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service, it is designed to give developers and businesses to build highly available and reliable infrastructure, and can also be used to route users to infrastructure running in both AWS and outside of AWS.

- [One-Click DNS Deployment](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://roble-files.s3.amazonaws.com/Hodan-Project/R53-failover.yml&stackName=HDN-Domain-Host)

Following architecture explains how our web server is being accessed in either public or private users

![Route 53 - Web Server](https://github.com/MoRoble/AWS-Projects/blob/9486cd9c6d3ee7e608d9372d210336b940c736d3/Amazon-Route53/Web-Server%20-%20R53-1.jpg)


Using split-horizon technique we are able provision web server that is partially being accessed by external users while internal users will be presented intranet.
