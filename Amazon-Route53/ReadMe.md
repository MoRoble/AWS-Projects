## Amazon Route-53

As part of our AWS Projects here's another useful project where I will go through the need for Hodan School to route their users accessing public or private resources in a reliable and cost effective way. I have suggested using Amazon cloud solutions in general and Amazon Route-53 to manage our domains which benefits fast, flexibility, security, scalability and hybrid cloud technology.

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service, it offers powerful policies for efficient DNS requests, it is designed to allow developers and businesses to build highly available and reliable infrastructure, and also set routing policy that best fits users needs to infrastructure running in both AWS and outside of AWS.

Hodan School has registered & hosted their domain elsewhere called GoDaddy, they have an old email system managed by local IT Engineers, they also have a local database server for HR to use. Hodan School wanted to post upcoming events, parent pay system, notices for parents to their website, and also music gallery, times of school day, exam result information, vacancies and many other.

Based on their current system I have built an architecture to cover Hodan School needs and to create an even more intelligent, automated and balanced system. I started transferring their domain from third part and created Route 53 public hosted zone which let me add Name Servers into DNS system for hodan.com
After successfully transferring hodan.com to Amazon Route 53 public hosted zones, I have created resource records to route & balance user requests with their respected authenticity. Then I have built an infrastructure server that hosts the domain, DataBase and Mail-server. I have also provisioned a static website through automated health checks away from servers that might be failing or certain threshold are exceeded then take over and tell users what the issue is and kindly apologize for any inconvenience might arise and how long will our system get back to live.

To distinguish users either internal or external when accessing organization resources I have used split-horizon technique of Route 53 that allows to intelligently detect traffic based on their source. Using one domain name our users are able to access our organisation website in public if they are connected from an outside organisation network and when an internal access users (staff) are able to get resources such as emails, shared files and local devices when connected from internal (intranet).

Here's a diagram for this project, it illustrates key actors for this project to keep it brief.


![Route 53 - Web Server](https://github.com/MoRoble/AWS-Projects/blob/9486cd9c6d3ee7e608d9372d210336b940c736d3/Amazon-Route53/Web-Server%20-%20R53-1.jpg)

To demonstrate this project I have created a cloud formation template that provisions web server, test machine and other related infrastructure, to simplify this just use one-click deployment method and refer the above diagram to help you finish the process.

- [One-Click DNS Deployment](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://roble-files.s3.amazonaws.com/Hodan-Project/R53-failover.yml&stackName=HDN-Domain-Host)

That's all!, our domain now points to relevant resources.

Join me on my next project. I am going to build phone system architecture using AWS cloud solutions and 3CX VoIP system integrated together which will result in reliable, secure and widely accessible throughout the network.

I hope that was informative and I would like to thank you. 
