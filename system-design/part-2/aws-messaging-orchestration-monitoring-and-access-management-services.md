# Chapter 12. AWS Messaging, Orchestration, Monitoring, and Access Management Services

This chapter covers AWS services used for coordination and communication among application components, including messaging, orchestration, monitoring, and access management services. Specifically, it delves into **Amazon Simple Notification Service (SNS)**, **AWS Step Functions**, workflow services, **Amazon CloudWatch**, **AWS Identity and Access Management (IAM)**, and **Amazon Cognito**.

## AWS Messaging and Streaming Services

AWS provides services like **Amazon Managed Streaming for Apache Kafka (MSK)**, **Amazon Kinesis**, **Amazon Simple Queue Service (SQS)**, and **Amazon SNS** to implement pub/sub (publisher-subscriber) design patterns and manage real-time data streams.

### Amazon Managed Streaming for Apache Kafka (MSK)

MSK is a managed service for **Apache Kafka**, an open source message broker and event-streaming platform. MSK manages control-plane operations (creating, updating, deleting clusters) and data-plane operations (producing and consuming events).

- **Cluster Setup and Availability:** When setting up an MSK cluster, customers specify the number and type of broker nodes and storage capacity in each Availability Zone (AZ). A minimum of two AZs must be selected for high availability.
- **Capacity Modes:** MSK offers both **serverless** (AWS manages infrastructure configuration) and **provisioned** capacity modes (customers select nodes and storage configurations).
- **Coordination:** MSK internally manages **ZooKeeper** nodes for coordination and synchronization among brokers, although recent versions (3.7.x) support the **KRaft** mode, which handles the ZooKeeper functionality.
- **Client Access Mechanisms:** Access can be configured via:
  - **Unauthenticated access** (not recommended).
  - **IAM role-based access**.
  - **SASL/SCRAM authentication** (credentials stored securely in AWS Secrets Manager).
  - **TLS authentication** (certificates stored in AWS Certificate Manager - ACM).
- **Data Security:** Data encryption is supported both **at rest** (using AWS-managed or customer-managed keys) and **in transit** (using TLS encryption for communication within the cluster and optionally between brokers and clients).
- **Use Cases:** MSK is typically used for data ingestion and then feeding data to other services like Kinesis Data Firehose (KDF), AWS Lambda, or Apache Flink for analysis.

### Amazon Kinesis

Kinesis is a suite of services for streaming, analytics, and ETL, including Kinesis Data Streams (KDS), Kinesis Data Firehose (KDF), Kinesis Data Analytics (KDA), and Kinesis Video Streams (KVS).

#### Amazon Kinesis Data Streams (KDS)

KDS is used to ingest, store, process, and analyze huge volumes of data streams in near real time.

- **Shards:** A **shard** is the basic throughput unit in KDS, an identified sequence of data records in a stream. A single shard can ingest up to **1 MB/s** (1,000 TPS) and emit up to **2 MB/s**.
- **Capacity Modes:** KDS supports **provisioned mode** (customers configure the number of shards) and **on-demand mode** (AWS automatically manages scaling).
- **Data Record Structure:** Records include a **sequence number** (auto-assigned and unique per partition key within the shard), a **partition key** (determines which shard the data record belongs to), and a **data blob** (immutable sequence of bytes, max 1 MB).
- **Enhanced Fan-Out (EFO):** This feature provides a dedicated pipe for each consumer, mitigating the 2 MB/s fan-out limitation at the shard level.
- **Data Retention:** Data is temporarily stored for **24 hours up to seven days**, allowing replaying for retry strategies.
- **Comparison with MSK (Table 12-1 Highlights):**
  - **Logical Entity:** KDS uses **shards** (number must be specified), while MSK uses **partitions** (number of brokers must be configured).
  - **Latency:** KDS offers low latency (data available within 200 ms, or lower with EFO).
  - **Message Delivery:** KDS offers **at-least-once** delivery semantics, requiring application idempotency to handle potential duplicates. MSK supports **exactly-once** delivery semantics.
  - **Data Retention:** KDS retention can be increased up to one year, while MSK retention depends on the allocated broker storage and can be suitable for retaining data for over a year.

#### Amazon Kinesis Data Analytics (KDA)

KDA is a fully managed, serverless service for **Apache Flink** capabilities, automatically scaling to handle desired data throughput,. It processes, queries, and analyzes streaming data in near real time, sending it to destinations like KDS, MSK, S3, and OpenSearch.

- **Apache Flink:** Flink is an open source distributed processing engine supporting **bounded** (batch processing) and **unbounded** (real-time streaming) data streams. Flink performs stateful computations in memory for low latency and ensures **exactly-once** processing via asynchronous checkpointing to durable storage.
- **KDA Features:** It provides serverless operation, easy integration with many AWS services (KDS, MSK, S3, OpenSearch, etc.), and supports KDA Studio (Apache Zeppelin serverless notebooks) for interactive data analysis using SQL, Scala, and Python.

#### Amazon Kinesis Data Firehose (KDF)

KDF is a service for delivering live streaming data to various destinations (S3, OpenSearch, Redshift, Splunk, or custom HTTP/HTTPS endpoints). It is fully managed and serverless, but **it offers no storage of its own** and thus no message replaying feature.

- **Transformations:** KDF can transform data before delivery using built-in options (like conversion to Apache Parquet format) or custom transformations via AWS Lambda functions.
- **Buffering:** KDF buffers incoming data by size (e.g., 1–128 MB for S3) or time (e.g., 60–900 seconds) before delivery.
- **Delivery Semantics:** KDF supports **at-least-once** data delivery semantics, meaning data duplication is possible at the destination due to retry mechanisms.

#### Amazon Kinesis Video Streams (KVS)

KVS is optimized for delivering **live streaming video data** in near real time from millions of sources to AWS for processing, such as running ML algorithms or custom video processing.

- **Features:** KVS offers durable data storage with configurable retention periods, automatically encrypts data at rest and in transit, and creates an index based on timestamps for quick access. It is a fully managed, serverless offering.

### Amazon Simple Queue Service (SQS)

Amazon SQS is a fully managed AWS queue service that automatically scales and requires no maintenance.

- **Use Cases:** SQS is suitable for **application decoupling** (services communicate via SQS) and **back pressure control** (consumers process messages at their own rate),. Messages are kept for a maximum of 14 days.
- **Visibility Timeout:** The time a message is hidden from other consumers after it is received by one consumer; it ranges from zero seconds to 12 hours.
- **Retention Period:** The time a message is kept in the queue if not received; it ranges from one minute to 14 days.
- **Dead Letter Queue (DLQ):** Used to push failed messages for later retry or debugging.
- **Maximum Message Size:** 256 KB, but larger content can be stored in S3 or DynamoDB and referenced in the SQS message.
- **SQS Types (Table 12-2 Highlights):**
  - **Standard Queue:** Offers **unlimited throughput** and **at-least-once** message delivery (message ordering is best-effort),.
  - **FIFO Queue:** Guarantees **message ordering** and **exactly-once** delivery,. Throughput is limited to 300 TPS (or 3,000 TPS with batching). FIFO queues are approximately 25% costlier than standard queues.

### Amazon Simple Notification Service (SNS)

Amazon SNS is an intermediary service for communication between producers and consumers (subscribers). A producer publishes a message to an SNS **topic**, and SNS forwards it to all subscribed endpoints via a **push mechanism**,.

- **Subscribers:** Supported consumers include KDF streams, SQS, Lambda, HTTP(S) endpoints, email, and mobile push notifications.
- **Comparison with SQS (Table 12-3 Highlights):**
  - **Delivery Mechanism:** SNS pushes messages to subscribers, while SQS requires applications to poll for messages.
  - **Parallelism:** SNS pushes messages to **all consumers in parallel**, whereas SQS ensures that only a single consumer accesses a message at a time.
- **Key Features:**
  - **Message Attributes and Filtering:** Optional metadata (key, value, type) can be sent with the message body and used to filter messages at the subscriber level,.
  - **Message Durability:** Messages are stored across multiple AZs before acknowledgment.
  - **Security:** Server-side encryption can be enabled using an AWS KMS key, which encrypts the message body when stored and decrypts it when forwarded to subscribers.
  - **Ordering:** SNS supports **FIFO topics** for strict message ordering and duplication prevention.

## Workflow Orchestration

AWS offers **AWS Step Functions** and **Amazon Managed Workflow for Apache Airflow (MWAA)** for coordinating complex workflows.

### AWS Step Functions

Step Functions is a fully managed, serverless, and visual workflow orchestration service that uses **state machines** to coordinate distributed application components.

- **State Machine:** Represents the orchestration workflow as a sequence of steps, defining relationships, input, and output.
- **Task:** A single step (state) in the state machine that executes specific work, such as calling Lambda or an API action of another AWS service.
- **Activity:** A Step Functions feature that allows workflow steps to wait for **Activity Workers** (e.g., applications on EC2, ECS, or Lambda) to poll for work and return an execution callback.
- **Language:** Workflows are defined using **Amazon States Language (ASL)**, a JSON-based structured language.
- **State Types:** Include **Pass** (passes input as output), **Task** (performs work), **Choice** (conditional branching), **Wait** (pauses execution), **Succeed** (successful termination), **Fail** (failure termination), **Parallel** (executes independent states concurrently), and **Map** (runs a set of steps in parallel for each item in a dataset, supporting both inline and distributed modes),,.
- **Workflow Types (Table 12-4 Highlights):**
  - **Standard Workflows:** Used for **long-running workloads** (up to one year) and durable, auditable workflows. Execution is **exactly once**.
  - **Express Workflows:** Used for **short-lived** (up to five minutes), high-volume, event-processing workloads. Execution is **at least once** for asynchronous mode and **at most once** for synchronous mode. Express workflows **do not support Activities**.

### Amazon Managed Workflow for Apache Airflow (MWAA)

MWAA is a managed service for **Apache Airflow**, an open source tool that uses **Directed Acyclic Graphs (DAGs)** to programmatically create, schedule, and monitor workflows,.

- **Architecture:** Airflow uses a **Scheduler** to trigger workflows, an **Executor** to determine task execution style, a **Web Server** for the UI, and a **Metadata Database** to store task/workflow states,.
- **MWAA Features:** AWS manages infrastructure and capacity (workers and schedulers), provides security via IAM roles, KMS encryption, and VPC deployment. Monitoring is integrated with Amazon CloudWatch.

## Monitoring and Logging

### Amazon CloudWatch

CloudWatch is the primary AWS service for monitoring application health and debugging issues, providing storage and search capabilities for application logs, visualization of metrics, dashboards, and alerts,.

- **Application Logs:** Logs are published in real time and stored in **log streams** (sequence of log events) within **log groups** (streams with similar properties, retention, and access controls). **Log Insights** allow interactive search, analysis, and visualization using a supported query language.
- **Metrics:** A time-ordered set of data points for visualization.
  - **Namespace:** Root-level identifier to distinguish metrics.
  - **Dimension:** Metric identification property (name-value pairs).
  - **Statistics:** Used for data aggregation (max, min, average, percentile, sum, etc.).
- **Alarms:** Monitor metrics and notify users when configurable thresholds are breached. Alarms can be configured using **static thresholds** or **anomaly detection**. Supported actions include **notification** (via SNS), **autoscaling**, **EC2 actions** (reboot, stop, terminate), and **Systems Manager** actions. A **composite alarm** can monitor the state of multiple child alarms.
- **CloudWatch Events / Amazon EventBridge:** Events stream state changes from AWS services/resources in near real time to a target. **EventBridge** is an enhanced version offering:
  - **Integration with SaaS providers** over private AWS networks.
  - **Custom event buses** for better control and access management.
  - **Enhanced rules** for content-based filtering.
  - **Schema registry** for storing and referencing schemas.

## Access Management

### AWS Identity and Access Management (IAM)

IAM enforces security measures for authentication (AuthN) and authorization (AuthZ) for AWS resources. The principle of **least privilege** (providing only the minimum required permissions) is recommended.

- **Root User:** Created upon account setup with full administrative access; explicit IAM policies cannot deny access (only SCPs can limit permissions in member accounts).
- **IAM User:** Represents a person or service with long-term credentials (username/password or access keys); should be avoided in favor of roles where possible.
- **IAM Group:** Groups users with the same set of permissions.
- **IAM Role:** Assumed temporarily by a person, service, or AWS account to perform a task; recommended over IAM users,.
- **IAM Policy:** A JSON object defining a set of permissions attached to an IAM identity or an AWS resource. It includes `Effect` (Allow or Deny), `Action` (resource operations), and `Resource` (specific resources).

### Amazon Cognito

Cognito is a fully managed, highly scalable Customer Identity and Access Management (CIAM) service for setting up and managing identity pools for AuthN and AuthZ.

- **Identity Provider (IdP):** Stores and manages digital identities (e.g., Google, Facebook, Amazon). Cognito can act as an IdP itself.
- **User Pool:** A user directory that acts as an IdP, supporting features like sign-up, login, password policy, and MFA.
- **Identity Pool:** Provides ** temporary credentials** for both authenticated and nonauthenticated users using valid tokens (e.g., JWT). This allows users to access AWS resources (like S3) using temporary roles.
- **Session Management:** **JSON Web Tokens (JWTs)** are often used for session management; the application can validate the token in memory to skip repetitive database lookups for every API call.

### AWS AppSync

AppSync is a fully managed, serverless GraphQL service providing a **single GraphQL endpoint** to query multiple databases, microservices, and APIs in a single network call.

- **Use Cases:** Exposing a unified API to frontends and simplifying complex data retrieval from disparate backends,. It also supports real-time pub/sub APIs via fully managed WebSocket connections.
- **Components:** Includes a **GraphQL schema** (data model), **Resolvers** (links schema to data sources), and **Data Sources** (DynamoDB, RDS, Lambda, HTTP endpoints, etc.).
- **Merged API:** A single AppSync API created by merging multiple source APIs, supporting collaboration between independent teams.
- **Benefits:** Removes operational overhead for AuthN/AuthZ, caching, and encryption, and is fully serverless.
