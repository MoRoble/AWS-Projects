
> a brief about modules

Modules allow for the organization and reusability of Terraform code, breaking down infrastructure into smaller components. Nested modules further organize and reuse code, creating a hierarchy of modules. The use of modules provides several benefits, including standardizing infrastructure for an organization, managing dependencies between resources, easy testing and validation of infrastructure, and managing different environments. Modules provide a powerful way to improve consistency, reliability, and security of infrastructure while making it easier to test and validate changes. [Read More](https://github.com/MoRoble/AWS-Projects/tree/main/DataBase-Migration/modules)

### Breif

The current project requires a robust and sophisticated architecture, thus it has been divided into two phases. The first phase involves migrating a simple WordPress web application from an on-premises environment to Amazon Web Services (AWS). The on-premises environment will be a virtual web server, which is simulated using Amazon Elastic Compute Cloud (EC2), and a self-managed MariaDB database server running on the same EC2 instance.

The migration process will involve cloning the current setup of the on-premises EC2 webserver, including its configurations and dependencies, to a cloud-based EC2 instance. This will ensure that the application continues to run smoothly in its new cloud environment, with minimal downtime or disruption to operations. 

In the second phase of the project, the architecture will be further enhanced by utilizing separate EC2 instances for the WordPress application and RDS (MariaDB) database. This architecture will provide a higher level of security, reliability, and scalability compared to the previous version.

The migration of the on-premises WordPress EC2 and RDS managed SQL database will follow the completion of the architecture upgrade, ensuring a smooth transition and minimal disruption to operations. This migration will bring the web application to a state-of-the-art infrastructure, providing the necessary support for growth and scalability.

[**Phase I**](https://github.com/MoRoble/AWS-Projects/tree/main/DataBase-Migration/phaseI-DBMS)
