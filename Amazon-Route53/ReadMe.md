## Amazon Route-53
<!-- wp:paragraph -->
<p>This is another part of a series of projects I posted on GitHub related to upgrading legacy systems to Cloud Technology using AWS Solutions Architect such as Site-to-Site VPN, EFS, Amazon Route-53 and many more coming. Here’s another project where I will go through the need for the organizations to distinguish their resources when accessing in private or public.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Following our upgrade process for Hodan Secondary School, I am going to apply a high-level concept inside Route-53 to manage domains and route traffic according to public or private resources accessibility, and it helps flexibility, fast, security, scalability, and hybrid cloud technology.</p>
<!-- /wp:paragraph -->


![Route 53 - Web Server](https://github.com/MoRoble/AWS-Projects/blob/9486cd9c6d3ee7e608d9372d210336b940c736d3/Amazon-Route53/Web-Server%20-%20R53-1.jpg)

To demonstrate this project I have created a cloud formation template that provisions web server, test machine and other related infrastructure, to simplify this just use one-click deployment method and refer the above diagram to help you finish the process.

- [One-Click DNS Deployment](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://roble-files.s3.amazonaws.com/Hodan-Project/R53-failover.yml&stackName=HDN-Domain-Host)


##### Further details to this project visit [my blog](https://roble.uk/amazon-route-53/)

Join me on my next project. I am going to build phone system architecture using AWS cloud solutions and 3CX VoIP system integrated together which will result in reliable, secure and widely accessible throughout the network.

I hope that was informative and I would like to thank you. 
