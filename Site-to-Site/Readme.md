## Site-to-Site VPN connection

On this project I will be collaborated with Eng. Hamdi, which I believe with her amazing talent will help me achieve this project to finish in a fruitful way. This section provides an overview of the recommended initial Site-to-Site VPN architecture and highlights several important VPN connection options. I recently implemented an AWS site-to-site VPN for Hodan School to connect their on-premise network to their newly deployed AWS account.

The requirement was network level connectivity from their on-premise network (Unifi Security Gateway) to their management VPC. Support of allowing to share file data from multiple EC2’s or on-prem instances simultaneously.

The setup of this was simple from an AWS perspective. With Cloud Formation we deployed a Customer Gateway (CGW) using the IP address of their on-premise firewall, created a Virtual Private Gateway (VPG) and then the VPN Gateway (VPN).

![Hodan School](https://github.com/MoRoble/AWS-Projects/blob/main/Site-to-Site/600-Hodan-School-S2S.png)
