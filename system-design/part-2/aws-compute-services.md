# Chapter 11. AWS Compute Services

This chapter introduces the compute services offered by AWS, focusing on how to select the appropriate resource type and size for various workloads. These services range from virtual servers similar to traditional personal computers (Amazon EC2) to serverless options (AWS Lambda) and containerization platforms (ECS and EKS),. A **server** is defined as a computer that is running most of the time to serve requests.

## Amazon Elastic Compute Cloud (EC2)

Amazon EC2 is a **scalable virtual server hosting service** that allows the creation of virtual machines (VMs) in the AWS cloud, referred to as **instances**.

### Instance Deployment Options

Customers can choose between bare-metal servers or virtualized environments managed via a hypervisor:

- **Bare-metal server:** These are physical servers dedicated to a single tenant. They are suitable for workloads that require **direct access** to the underlying Intel Xeon processor infrastructure (e.g., Intel virtualization - VT-x) or have strict compliance requirements.
- **Hypervisor:** This is a virtualization component that runs multiple VMs on a single physical server and allocates resources like CPU and memory to them. AWS supports **Xen** and **Nitro** hypervisors, with the Nitro system providing enhanced security and performance.

### Amazon Machine Image (AMI)

The configuration of an EC2 instance is determined by the **Amazon Machine Image (AMI)**.

- **Definition:** An AMI is a **preconfigured template** that defines the OS, storage volumes, dependencies, custom security settings, and other configurations required to provision EC2 instances efficiently,.
- **Source:** AMIs can be obtained for free from the AWS community (e.g., Amazon Linux), purchased from third parties (e.g., Red Hat), or custom-created.
- **Considerations:** AMIs are **region-specific** but can be copied to other regions. They are tied to a specific OS and architecture (32-bit or 64-bit).
- **Root Device Storage:** AMIs are backed by either **Amazon EBS** or **instance store**; this choice affects data persistence, size limits (EBS up to 64 TB, instance store up to 10 GB), and boot time.

### Instance Types

**Instance types** define the hardware and performance characteristics (CPU, memory, storage, networking) of an EC2 instance.

- **General-purpose instances:** Maintain a balance across compute, memory, and network resources, suitable for most general workloads.
- **Compute-optimized instances:** Suitable for **CPU-intensive workloads**, such as high-performance computing (HPC) or big data analytics.
- **Memory-optimized instances:** Designed for workloads requiring **large dataset processing in RAM** (e.g., in-memory caches).
- **Storage-optimized instances:** Suitable for workloads requiring high sequential read/write access to local storage (e.g., databases).
- **Accelerated-computing instances:** GPU-based instances suitable for ML, computational finance, and HPC.

### EC2 Cost Optimization and Configuration

- **Configuration:** EC2 instances require selecting a **key pair** for SSH access. They are launched at the **Availability Zone (AZ) level** within a region.
- **Reserved EC2 instance capacity:** Used when minimum capacity is known for a long period, offering up to **72% discount** compared to on-demand pricing based on one- or three-year commitment.
- **Spot instances:** Less expensive than on-demand instances, suitable for **noncritical workloads** that can tolerate instance termination.

## Autoscaling

**Autoscaling** is an AWS feature that automatically adjusts the number of EC2 instances in a collection in response to changing workload demands.

- **Autoscaling Groups (ASGs):** These collections of EC2 instances can be configured with minimum and maximum instance limits.
- **Scaling Policies:** Configured to scale based on metrics like CPU utilization or network traffic.
- **Benefits:** Ensures seamless scaling up or down to handle traffic spikes, reduces costs during low demand, and ensures a fixed number of instances are always running and healthy,.
- **Reliability:** Autoscaling can automatically replace failed instances. Instance launch latency for scaling up can be mitigated by **prescaling** instances for expected spiky traffic.
- **Cooldown Period:** A configurable period (default is 300 seconds) after a scaling activity completes, during which AWS waits before initiating further scaling actions, ensuring ASG stability.

## AWS Lambda

AWS Lambda is a **fully managed, serverless compute service** that allows users to run code (called a **Lambda function**) without managing servers,.

- **Function and Event:** The Lambda function is the application codebase, and it is executed in response to a **trigger** (e.g., an AWS service or custom event),.
- **Execution Environment:** A secure, isolated runtime environment created internally by Lambda, configured based on language, memory, and execution time (maximum supported is **15 minutes**).
- **Architecture:** Supports ARM64 (AWS Graviton2) and x86-64 processors; ARM64 is recommended for cost and performance efficiency.
- **Deployment:** Code can be deployed via a **.zip file** (max 250 MB in S3) or a **container image** (max 10 GB in Amazon ECR, must include OS/runtime),.
- **Layers:** Zipped common code/libraries that can be attached to reduce the function code bundle size and startup time.

### Lambda Invocation Modes

Lambda supports three primary invocation types:

| Mode             | Description                                                                                      | Use Case/Trigger Example              | Consistency                                                                                                                    |
| :--------------- | :----------------------------------------------------------------------------------------------- | :------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------- |
| **Synchronous**  | Customer waits for a response until execution completes.                                         | API Gateway, ALB, AWS CLI             | Preferred for latency-sensitive workloads (max 15 min execution, shorter for some triggers, e.g., API Gateway max 29 seconds). |
| **Asynchronous** | Response is returned immediately; request is queued for processing.                              | S3, SNS, CloudWatch events            | Supports retries; invocation responses can be routed to a configured **Destination** (SNS, SQS, etc.),.                        |
| **Polling**      | Lambda polls stream/queue services (Kinesis, SQS, Kafka) and synchronously invokes the function. | DynamoDB streams, SQS queues, Kinesis | **AWS does not charge customers for message polling**.                                                                         |

### Cold Start Mitigation

The **cold start** problem occurs when Lambda provisions resources and prepares a new **execution environment** (downloading code, setting memory/runtime, executing initialization code), causing increased request processing time.

- **Warm Start:** The execution environment is retained after execution to serve subsequent requests, skipping the setup phase.
- **Provisioned Concurrency:** Ensures the execution environment is set up in advance, ready to serve requests immediately.
- **Memory Configurations:** Compute power is proportional to configured memory (128 MB to 10,240 MB); tuning memory improves performance.
- **SnapStart (Java 11):** Improves startup time by resuming execution from an encrypted snapshot of the initialized environment,.

## Containerization Services

AWS offers container orchestration using Amazon Elastic Container Service (ECS) and Amazon Elastic Kubernetes Service (EKS).

### Amazon Elastic Container Service (ECS)

ECS is a fully managed, highly available container orchestration service that integrates with other AWS services (EC2, ECR, ELB).

- **Terminology:**
  - **Task:** The basic deployment unit, running one or more containers.
  - **ECS Service:** Groups tasks for scaling and monitoring.
  - **ECS Cluster:** A logical grouping of infrastructure running tasks (Fargate or EC2 launch types).
  - **Task Definitions:** Define configurations for a task (runtime, resources, containers).
  - **Amazon ECR:** Managed container image registry.

### ECS Launch Types Comparison

| Comparison Factor          | Amazon ECS EC2                                                                                                                                      | Amazon ECS Fargate                                                                                             |
| :------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------- |
| **Operational Management** | Customer manages compute (instance type, scaling, OS patching).                                                                                     | **Serverless**; AWS manages server maintenance. Customer specifies OS, vCPU, memory, autoscaling.              |
| **Pricing**                | Customer charged for EC2 instance running time plus storage.                                                                                        | Charged based on active workload: vCPU, memory, CPU architecture, and storage selection.                       |
| **Use Cases**              | High CPU/memory requirements, cost optimization, need for **persistent storage access (EBS)**, or compliance requiring self-managed infrastructure. | Low overhead, small workloads, occasional bursts, or batch workloads.                                          |
| **Limitations**            | Customer incurs operational overhead (patching, instance selection).                                                                                | No support for GPU or EBS volumes; fewer customizations available. Can use EFS volumes for persistent storage. |

### Amazon Elastic Kubernetes Service (EKS)

EKS is a **fully managed Kubernetes service** that simplifies the deployment, management, and scaling of containerized applications using the open source Kubernetes platform on AWS.

- **Management:** EKS manages the Kubernetes control plane (API server, etcd persistence database), reducing administrative overhead. The EKS control plane runs in three AZs for high availability.
- **Scaling:** EKS uses Amazon EC2 instances/ASGs or Fargate for dynamic scaling of worker nodes. It can leverage **EC2 spot instances** to reduce cluster costs.
- **Features:** Provides **automated Kubernetes version upgrades**. Supports hybrid deployments using **EKS on AWS Outposts** for running applications at on-premises data centers.
- **Security and Compliance:** Integrates with AWS IAM for access control, VPC for network policies, and AWS KMS for encryption; compliant with various regulations (e.g., SOC, PCI DSS, HIPAA).
- **Ecosystem:** Benefits from the open source Kubernetes community and is compatible with Kubernetes-native tools.

## Guidance on Compute Platform Selection

Selecting the right compute platform is a critical decision, viewed as a "two-way door" that can be reiterated as requirements change,.

- **Flexibility:** **EC2** offers **maximum flexibility** and hardware control, but this comes with a larger **operational overhead** (OS patching, maintenance). **AWS Lambda** provides maximum abstraction, focusing only on code.
- **Learning Curve:** Choosing a service based on **familiarity** (e.g., Lambda for beginners) minimizes time to launch applications.
- **Traffic Patterns:** EC2/ECS EC2 is better suited for **high-latency sensitive operations** or GPU-accelerated computing.
- **Cost:** The pricing models vary; the total cost should account for the operational overhead associated with each choice.
