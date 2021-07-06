## Site-to-Site VPN connection

I have recently implemented an AWS site-to-site VPN for Hodan School to connect their on-premise network to their newly deployed AWS account.On this project I will be collaborating with Eng. Hamdi, which I believe with her amazing talent will help me to finish it in a fruitful way.

AWS Site-to-Site VPN is a fully-managed service that creates a secure connection between your data center or branch office and your AWS resources using IP Security (IPSec) tunnels. We’re going to move applications to the cloud according to Hodan School requirements and AWS S2S VPN connection is an easier enhanced technology to move between your network and the AWS cloud. You can host Amazon VPCs behind your corporate firewall and seamlessly move your IT resources, without changing the way your users access these applications.

In our first meeting we have discussed the requirements and weaknesses that Hodan School reported to us, then we have set a plan to do this project so all participants are shared tasks equally in a way that no one feels overworked. I have tasked Hamdi to write infrastructure code using either Terraform or Cloud Formation, get quotations of equipment to facilitate this project and presentation of this project to the customer.

The requirement was network level connectivity from their on-premise network (Unifi Security Gateway) to their management VPC. Support for sharing file data from multiple EC2’s or on-prem workstations simultaneously, as well as application migration.

![Hodan School](https://github.com/MoRoble/AWS-Projects/blob/main/Site-to-Site/EFS-S2S-diagram.jpg)

The setup of this was simple from an AWS perspective. With Cloud Formation we deployed a Customer Gateway (CGW) using the IP address of their on-premise firewall, created a Virtual Private Gateway (VPG) and then the VPN Gateway (VPN). The on-premise configuration took a bit of research to get right but once configured correctly it worked as expected. Eng. Hamdi suggested getting a Unifi Router for its well architected interface and setup as she was making configuration steps for this stage of the project. On top of that Unifi is one of the leading networking devices in the market currently.
