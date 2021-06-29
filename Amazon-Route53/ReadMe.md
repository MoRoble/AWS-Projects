## Amazon Route-53

As part of our AWS Projects here's another usefull project where I will go through the need for Hodan School to route their users accessing public or private resources in a reliable and cost effective way. I have suggested to use Amazon cloud solutions in general and Amazon Route-53 to manage our domains which benefits a fast, flexibility, security, scalability and hybrid cloud technology.

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service, it is designed to give developers and businesses to build highly available and reliable infrastructure, and can also be used to route users to infrastructure running in both AWS and outside of AWS.

Hodan School have registered & hosted their domain elsewhere, they have an old email system managed by local IT Engineers, they also have local database server for HR to use. Hodan School wanted to post upcoming events, parent pay system, notices for parents to their website, and also music gallery, times of school day, exam result information, vacancies and many other.

Based on their current system I have built an architecture to cover Hodan School needs and to even more intelligent, automated and balanced system. I started transfering their domain from third part and created Route 53 public hosted zone which let me add Name Servers into DNS system for hodan.com

After successfully transfered hodan.com to Amazon Route 53, I have created resource records to route & balance user requests with their respected authenticity. Then I have built an inftrastructure server that hosts the domain, DataBase and Mail. I have also provisioned a static website when server outage or certain treshold are exceeded to take over and tell users the issue and how long will our system get back to live.

Here's a diagram for this project, it is illustrated key actors for this project to keep it brief.


![Route 53 - Web Server](https://github.com/MoRoble/AWS-Projects/blob/9486cd9c6d3ee7e608d9372d210336b940c736d3/Amazon-Route53/Web-Server%20-%20R53-1.jpg)

To practive this I have created a cloud formation template that provisions the infrastructure for this project, just use one-click deployment method and use the upove diagram to help you finish the process

- [One-Click DNS Deployment](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://roble-files.s3.amazonaws.com/Hodan-Project/R53-failover.yml&stackName=HDN-Domain-Host)

I hope that was informative and I would like to thank you.



Using split-horizon technique we are able provision web server that is partially being accessed by external users while internal users will be presented intranet.
