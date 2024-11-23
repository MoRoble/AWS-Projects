# Building and Managing Cloud-Native Microservices with Amazon ECS

In this project, I'll explore the capabilities I developed as a Platform Engineer while managing microservices on Amazon ECS. To streamline the process, I aimed to consolidate all the necessary infrastructure into a single repository, leveraging the advantages of a monorepo approach.

### Benefits of Using Amazon ECS
Using Amazon ECS (Elastic Container Service) compared to traditional methods where you might need to manually provision, configure, and manage servers. ECS offers several advantages that reduce administrative overhead:

1. **Managed Infrastructure**: ECS handles the orchestration of your containers, including scheduling, scaling, and load balancing, which simplifies the management of containerized applications.

2. **Integration with AWS Services**: ECS integrates seamlessly with other AWS services like IAM, CloudWatch, Elastic Load Balancing, AWS Cloud Map for service discovery and VPC, providing a cohesive ecosystem for your applications and reducing the complexity of managing these components separately.

### AWS ECS Build Architecture
Amazon ECS (Elastic Container Service) provides a managed environment for running containerized applications, and it offers two launch types: EC2 and Fargate. Each has its own advantages, and the choice depends on your specific needs and preferences.

#### EC2 Launch Type
- **Control Over Infrastructure**: You have full control over the EC2 instances, including instance types, networking, and storage. This is beneficial if you need specific configurations or have compliance requirements. For scaling you will need to use ASGs.
- **Custom AMIs**: You can use custom AMIs to meet specific needs, such as pre-installed software or security configurations.
- **Cost Management**: You can use Reserved Instances or Spot Instances to optimize costs.

#### Fargate Launch Type
- **Serverless**: With Fargate, you don't need to manage the underlying servers, it automatically provisions and scales the compute resources required to run your containers, allowing you to focus on your application rather than the infrastructure. You don't need to manage or provision EC2 instances.
- **Simplified Scaling**: Fargate automatically scales your containers based on demand, making it easier to handle varying workloads.
- **Pay-as-You-Go**: You pay only for the resources your containers use, which can be more cost-effective for certain workloads.

#### Choosing Between Fargate and EC2

When defining your ECS task, you can choose between two launch types: **Fargate** and **EC2**.

- **Fargate**: This is a serverless compute engine for containers. With Fargate, you don't need to manage the underlying EC2 instances. AWS handles the infrastructure, allowing you to focus solely on deploying and running containers. This option is ideal for users who want a simpler, hands-off experience and don't want to deal with the underlying infrastructure.

- **EC2**: This option gives you more control over the underlying infrastructure. You manage and configure the EC2 instances that run your containers. This is suitable for scenarios where you need more customization and control over the environment, such as running complex microservices architectures.

- **Compatibility**: ALBs are compatible with both EC2 and Fargate launch types in ECS. This means you can use ALBs regardless of whether you are managing your own EC2 instances or using the serverless Fargate option. If you are running your ECS tasks on EC2 instances, you will need to use ASG to manage the scaling of these instances.

To specify the launch type in your ECS task definition, you can set the `launch_type` parameter:

```hcl
resource "aws_ecs_task_definition" "my_task" {
  family                = "${var.project_name}-${var.environment}-td"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]  # or ["EC2"]
  cpu                   = "256"
  memory                = "512"

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-container-d"
      image     = "${var.container_image}"
      essential = true
      ...
    }
  ])
}
```

Both options provide the benefits of container orchestration and integration with AWS services, but the choice depends on your specific needs and how much control you want over the underlying infrastructure.

#### Key Amazon ECS Resources

- **aws_ecs_cluster**: This resource defines the ECS cluster where your tasks and services will run. It is the foundational resource that other ECS resources depend on.

- **aws_cloudwatch_log_group**: This resource is used to create a log group in CloudWatch for storing logs from your ECS tasks. It helps in monitoring and troubleshooting your applications.
  - When using Amazon ECS Fargate, you have a couple of options for monitoring your containers with Amazon CloudWatch:
    - CloudWatch Container Insights: This service automatically collects metrics and logs from your containerized applications without needing to install a CloudWatch agent inside your containers. It gathers data such as CPU, memory, disk, and network usage, and provides diagnostic information like container restart failures.
    - CloudWatch Agent: If you need more detailed or custom metrics, you can install the CloudWatch agent as a sidecar container in your task definition. This agent can collect additional metrics and logs, which can be configured to meet your specific monitoring needs.
So, while CloudWatch Container Insights can monitor your containers without an agent, installing the CloudWatch agent as a sidecar container gives you more flexibility and control over the metrics and logs you collect.

- **aws_ecs_task_definition**: This resource defines the blueprint for your application, specifying the Docker image to use, CPU and memory requirements, and other configurations. It depends on the ECS cluster to run the tasks.

- **aws_ecs_service**: This resource ensures that the specified number of task instances are running and managed. It depends on the ECS task definition and the ECS cluster to deploy and manage the tasks.

#### How ECS components Depend on each other?

1. **aws_ecs_cluster**: The base resource that other ECS resources depend on. Without the cluster, there is no environment to run the tasks and services.
2. **aws_cloudwatch_log_group**: Used for logging and monitoring, can be referenced by ECS tasks. It depends on the ECS tasks to generate logs that need to be stored and monitored.
3. **aws_ecs_task_definition**: Depends on the ECS cluster to define how tasks should be run. The task definition specifies the details of the tasks that will run within the cluster.
4. **aws_ecs_service**: Depends on both the ECS task definition and ECS cluster to manage and run the tasks. The service ensures that the tasks defined in the task definition are running within the specified cluster.

### Built-in ECS Fargate Scaling compared to ASG
ECS Fargate does indeed have its own built-in scaling mechanisms, which can be managed through ECS Service Auto Scaling. This allows you to automatically adjust the number of running tasks in your service based on specified criteria, such as CPU or memory utilization.

#### Why Use `aws_appautoscaling_target` and `aws_appautoscaling_policy`?
*Granular Control*: Using `aws_appautoscaling_target` and `aws_appautoscaling_policy` gives you more granular control over the scaling behavior. You can define specific scaling policies and metrics that might not be covered by the default ECS Fargate scaling options.
*Custom Metrics*: You can scale based on custom CloudWatch metrics, not just the predefined ones like CPU and memory utilization. This allows for more sophisticated scaling strategies tailored to your application’s needs.
*Integration with Other AWS Services*: These resources allow you to integrate scaling policies with other AWS services, providing a unified approach to auto-scaling across your infrastructure.
*Advanced Scaling Policies*: You can implement advanced scaling policies, such as step scaling or target tracking scaling, which might offer more flexibility and efficiency compared to the default ECS Fargate scaling options.
**Use Case**
If you have a specific requirement to scale your ECS Fargate tasks based on a custom metric (e.g., the number of messages in an SQS queue), using `aws_appautoscaling_target` and `aws_appautoscaling_policy` would be the way to go.

For many use cases, the built-in ECS Service Auto Scaling is sufficient and easier to manage. It allows you to set up scaling policies directly within the ECS service definition, simplifying the process.

*Note*
The `aws_appautoscaling_target` and `aws_appautoscaling_policy` resources in Terraform are used to manage Application Auto Scaling for various AWS services, including ECS, DynamoDB, and Lambda.

#### The Role of Docker in Managing My Image 🚀

Have you ever heard the phrase, “But it works on my machine”? 😅 Many developers face this issue when an application works perfectly in development but fails in production. This can be due to differences in dependencies, libraries, frameworks, or OS-level features between environments.

Docker solves this problem by packaging applications with everything they need to run, making them portable across any environment. This simplifies collaboration between developers and operations teams, reduces deployment failures, and accelerates time-to-market.

I used **Docker** to create and manage container images. Docker capabilities include:
- **Image Management**: Building, storing, and distributing Docker images.
- **Orchestration**: Integrating with orchestration tools like Kubernetes and ECS for managing containerized applications at scale.

### Security Group Setup
Configuring security groups involves matching and managing ports and resources, which requires numerous trials to ensure the infrastructure is secure enough for public use. Here are the security groups we will create for this project:

1. **ALB Security Group**
   - **Ports**: 80 and 443
   - **Source**: 0.0.0.0/0 (from anywhere)

2. **Bastion Security Group**
   - **Port**: 22
   - **Source**: Your IP Address
   - **Note**: Only port 22 (SSH) can be accessed, and only from your workstation.

3. **Ansible Server Security Group**
   - **Port**: 22
   - **Source**: Bastion Security Group

4. **Webserver (App) Security Group**
   - **Ports**: 80 and 443
   - **Source**: ALB Security Group
   - **Port**: 22
   - **Source**: Ansible Security Group

5. **Data Server (RDS) Security Group**
   - **Port**: 3306
   - **Source**: Webserver (App) Security Group

## Skills Gained While Working on This Project

Working on this project will help you sharpen your skills in various AWS services and tools. The key AWS services you will utilize include:

- **ECS** (Elastic Container Service)
  - Capability: Deploying and managing containerized applications at scale.
- **ALB** (Application Load Balancer)
  - Capability: Distributing incoming application traffic across multiple targets for high availability.
- **ASG** (Auto Scaling Group)
  - Capability: Automatically adjusting the number of EC2 instances to handle the load for your application.
- **ECR** (Elastic Container Registry)
  - Capability: Storing, managing, and deploying Docker container images.
- **IAM** (Identity and Access Management) Roles, Policies, and Users
  - Capability: Managing secure access to AWS services and resources.
- **VPC** (Virtual Private Cloud)
  - Capability: Isolating your cloud resources within a virtual network.
  - **Subnets**
    - Capability: Segmenting your VPC into smaller networks.
  - **NAT Gateways**
    - Capability: Enabling instances in a private subnet to connect to the internet.
- **S3** (Simple Storage Service)
  - Capability: Storing and retrieving any amount of data at any time.
- **RDS** (Relational Database Service)
  - Capability: Setting up, operating, and scaling a relational database in the cloud.
- **CloudWatch**
  - Capability: Monitoring and managing your AWS resources and applications.

## Platform Engineer Capabilities

This project provided an opportunity to apply my core platform engineering skills, including managing containers on Amazon ECS, monitoring with CloudWatch, and configuring CI/CD pipelines with CodePipeline. Through this work, I gained hands-on experience with a range of AWS services. This project would be particularly beneficial for other platform engineers, as it includes capabilities such as:

* **Operating Systems**: Able to install software, packages, and script to automate system tasks.
* **Source Control**: Can amend, remove, squash, stage commits, and push/pull to/from a remote repository.
* **Cloud Observability**: Able to find errors from logs for different resource types and create alerts that are triggered in response to one or more metrics breaching thresholds.
* **Infrastructure as Code (IaC)**: Can author IaC configurations from scratch and know how to execute IaC configurations from the CLI.
* **CI/CD**: Able to work with an existing CI/CD pipeline, know how to find output logs, and understand the differences between repositories, jobs, pipelines, triggers, and schedules, and how they interact to implement a CI/CD solution.
* **Containers & Orchestration**: Able to create a Docker image and run it, publish Docker containers to a public repository, and understand the purpose and advantages of container orchestration.

### Infrastructure Management with Terraform

I managed all these configurations using **Terraform**, ensuring efficient and repeatable infrastructure deployment. Your skills will be enhanced in:

- **Resource Management**: Managing the lifecycle of infrastructure resources, including creation, update, and deletion.

<details>
  <summary>The most essential Terraform commands I use regularly include:</summary>
  
  - `terraform init`: Initializes a working directory with Terraform configuration files.
  - `terraform plan`: Generates an execution plan for actions to be taken.
  - `terraform apply`: Implements changes described in the configuration.
  - `terraform destroy`: Deletes all resources in the configuration.
  - `terraform validate`: Checks syntax and validity of configuration files.
  - `terraform refresh`: Updates the state file based on real resources.
  - `terraform output`: Displays output values from the state.
  - `terraform state list`: Lists resources in the state.
  - `terraform show`: Shows the current state in a human-readable format.
  - `terraform import`: Imports existing infrastructure into Terraform.
  - `terraform fmt`: Rewrites configuration files to a standard format.
  - `terraform graph`: Visualizes the Terraform dependency graph.
  - `terraform providers`: Prints a tree of used providers.
  - `terraform workspace commands`: Manage workspaces effectively.
  - `terraform state management`: Handle state with commands like pull, push, and remove.
  - `terraform taint` and `untaint`: Mark or unmark resources for recreation.
  - `terraform plan -out` and `apply -target`: Save plans or apply changes to specific resources.
  - `terraform apply -var`: Set variable values directly in the command line.
  - `terraform apply -var-file`: Use files for variable definitions.
  
</details>

