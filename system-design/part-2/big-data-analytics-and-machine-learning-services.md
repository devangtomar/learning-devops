# Chapter 13. Big Data, Analytics, and Machine Learning Services

This chapter covers AWS services that help process and analyze large volumes of data, specifically focusing on **Big Data, Analytics, and Machine Learning (ML) services**. The goal is to derive valuable insights from existing data (stored) or live streaming data, such as identifying the most ordered food items by location or the highest-rated restaurants in an area.

The chapter is divided into two main sections:

1.  **AWS Big Data and Analytics:** Services for processing large-scale data.
2.  **Machine Learning on AWS:** Services and infrastructure for running ML workloads,.

## AWS Big Data and Analytics

Data generated today is characterized by its massive **volume**, **velocity** (speed of production), and **variety** (different forms), demanding specialized tools for storage and processing. AWS provides specific tools for storing and processing big data, including:

- **Amazon Elastic MapReduce (EMR)**
- **AWS Glue**
- **Amazon Athena**
- **Amazon QuickSight** (Business Intelligence)
- **Amazon Redshift** (Data Warehouse).

### Amazon Elastic MapReduce (EMR)

Amazon EMR is a **managed service** that simplifies running big data processing frameworks and tools, such as **MapReduce, Apache Spark, Apache Hive, Apache HBase, and Presto**. EMR allows customers to launch clusters in minutes to execute large data-processing workloads, eliminating the operational burden of setting up and managing large clusters.

#### EMR File System (EMRFS)

While open source Hadoop clusters default to using HDFS (Hadoop Distributed File System) for storage, EMR offers EMRFS, a connector that links EMR clusters to **Amazon S3**. EMRFS uses S3 as the filesystem for data processing, streaming data directly to S3 while using HDFS for intermediate storage.

**Benefits of EMRFS over HDFS:**

- **Decoupled Storage and Compute:** EMRFS allows **multiple EMR clusters to access the same data from S3**, enabling compute and storage to scale independently.
- **Cost-Efficiency:** Data durability is handled by S3, eliminating the need to pay for HDFS replication (e.g., three times the storage cost for a replication factor of three).
- **Persistence:** Since storage is maintained in S3, clusters can be terminated to save compute costs while data persists.

**EMRFS Best Practices:**

- **Partitioning:** Data should be partitioned to ensure EMR clusters only fetch necessary data, resulting in faster retrieval and reduced costs.
- **File Size and Compression:** Files smaller than 128 MB should be avoided to minimize S3 calls. Compression should be used to save storage and network costs,.
- **File Formats:** Columnar formats like **Apache Parquet and Apache ORC** are recommended for queries focused on a subset of columns, while **Apache Avro** (row-optimized) is better for row-subset queries.

#### EMR Cluster Architecture

An EMR cluster running on EC2 instances can have three types of nodes:

1.  **Primary Node:** The cluster's primary node, which runs the **YARN resource manager** and the **HDFS NameNode** service for job tracking and health monitoring.
2.  **Core Node:** Runs the data daemon for **HDFS data storage** and the task tracker daemon for computation tasks. A cluster can have a maximum of one core instance group.
3.  **Task Node:** Provides **extra computation power but no data storage**. Up to 48 task instance groups can be configured. The application primary for any job runs on the core node to prevent job termination if a task node fails (e.g., if using EC2 spot instances),.

**Cost Optimization and Reliability:**

- **Cost Savings:** Clusters can be configured to **auto-terminate** upon job completion. EC2 **spot instances** can be leveraged for noncritical workloads, especially for **task nodes**, offering up to a 90% discount,. Autoscaling policies help manage variable workloads.
- **Reliability:** Deploying instances across **multiple Availability Zones (AZs)** and using multiple primary nodes ensures high availability and fault tolerance. Critical data should be stored in S3 instead of local HDFS.

### AWS Glue

AWS Glue is a **fully managed, serverless data integration service** for big data analytics tasks, focusing on Extract, Transform, and Load (ETL) operations,.

**Key Components and Concepts:**

- **Data Catalog:** Maintains databases that consist of one or more **metadata tables** inferred by a classifier.
- **Data Crawler:** Crawls data from sources like S3, infers the schema using a **classifier**, and creates necessary tables or partitions in the Data Catalog. Crawlers can be scheduled to automatically figure out modifications for frequently changing data schemas.
- **Table Partitioning:** A way to improve query performance, typically by dividing data into folders in S3 (e.g., Year/Month/Day structure). Partition indices can be created to avoid loading all partitions.
- **Data Engine:** Runs data-processing jobs. Glue supports **AWS Glue for Apache Spark** (for distributed ETL code in Python/Scala, batch processing, and live streaming), **AWS Glue for Ray** (for distributed Python execution, supporting scaling to hundreds of nodes), and **AWS Glue for Python Shell** (single-node Python engine),.
- **DPUs (Data Processing Units):** Workers used to run Glue jobs; customers configure the type of worker required.
- **Schema Registry:** A registry used to publish schemas and enforce data-streaming service integrations (e.g., MSK, KDS).

**Features and Considerations:**

- **Serverless and Autoscaling:** Glue automatically scales using DPUs and supports **autoscaling** to optimize compute costs.
- **Cost Optimization:** The **Flex job type** offers cost savings (up to 34%) and is suitable for noncritical workloads,.
- **Data Quality/PII:** Features include **Data Quality** (automatically validates data quality) and **PII** (detects and masks sensitive data),.
- **Version Control:** Offers easy integration with GitHub and AWS CodeCommit for source version control.

### Amazon Athena

Amazon Athena is a **fully managed, serverless big data analysis tool** that supports **SQL query execution on data stored directly in Amazon S3**. It eliminates the need to transfer data elsewhere for analysis.

**Key Features:**

- **Serverless Operation:** Customers do not manage infrastructure; AWS handles provisioning and workload management.
- **Federated Query:** Allows running SQL queries against data stored in a **variety of data stores** (e.g., DynamoDB, on-premises sources), not just S3. This is achieved using **Lambda-based data source connectors**.
- **User-Defined Functions (UDFs):** Allows writing **custom Java code on Lambda** that can be invoked directly from SQL queries for preprocessing or postprocessing data (e.g., masking sensitive data).
- **ML Models:** Deployed ML models on **Amazon SageMaker** can be invoked directly within a SQL query for data analysis (e.g., detecting negative reviews).
- **Workflow Integration:** Athena execution can be orchestrated via AWS Step Functions or scheduled using Amazon EventBridge.

### Amazon QuickSight

Amazon QuickSight is a **fully managed, serverless business intelligence service** offering analytics, visualization, and reporting. It can connect to multiple data stores (AWS data, third-party data, SaaS data, spreadsheets) to create unified dashboards.

**Key Features:**

- **Data Sources:** Integrates with various data sources, including Amazon Redshift, to provide centralized dashboards,.
- **SPICE Engine:** Supports fast advanced calculations using **SPICE (Super-fast, Parallel, In-memory Calculation Engine)**.
- **QuickSight Q (Enterprise Edition):** A **natural language processing** tool allowing users to query data by directly asking questions (e.g., "What are the top five restaurants in Mumbai?").

### Amazon Redshift

Amazon Redshift is a **data warehousing tool** that serves as a single data store for data from multiple sources, enabling SQL queries for data analytics. It is a managed service that scales to petabytes of data, with both **elastic scaling** and a **serverless option**.

**Architecture and Query Processing:**

- **Columnar and PostgreSQL-based:** Redshift is a **columnar storage solution** based on PostgreSQL.
- **Leader-Follower Cluster:** A leader node acts as a **query coordinator**, parsing and compiling the query before forwarding it to multiple parallel **compute nodes**. Clusters can scale from 2 to 128 nodes.
- **Data Storage:** Data is stored in immutable blocks of 1 MB, where a block contains column data spanning multiple rows.
- **Zone Maps:** **In-memory metadata** that stores minimum and maximum values for a block, helping to effectively **prune** data blocks irrelevant to a specific query. Optimization relies on setting a **sort key**.
- **Distribution Style:** Redshift allows configuring how data is distributed across compute node slices to ensure even distribution and optimal parallel processing. Styles include **EVEN** (round-robin, recommended when no join operations exist), **KEY** (based on column value, ensuring related data is colocated), and **ALL** (entire table copied to every node, recommended only for small/static tables),.

**Scaling and Integration:**

- **Redshift Spectrum:** Allows customers to use **S3 as storage** and query data directly from S3 without loading it into the cluster.
- **Redshift Managed Storage (RMS):** Enables **independent scaling of compute and storage**. It uses S3 for persistent storage and high-speed, SSD-backed, Tier 1 cache support.
- **Materialized Views:** Used to speed up queries by storing **precomputed result sets** (based on joins, aggregations, or filters).
- **WLM (Workload Management):** Tools to separate different query workloads and assign priority, enabling throttling or aborting less important queries.
- **Data Ingestion:** Supports loading data from S3, DynamoDB, EMR, or remote hosts using the `COPY` command. It also integrates with MSK or KDS for ingesting live streaming data,.
- **Federated Query:** Accesses live data from external data stores (e.g., RDS/Aurora PostgreSQL and MySQL) without loading it.

## Machine Learning on AWS

AWS provides various ML and AI services, ranging from building and running custom ML models to leveraging fully customized applications for specific purposes (e.g., Amazon Polly, Amazon Comprehend). These services are categorized into three areas:

1.  **Application Services:** Customized solutions for specific use cases (e.g., Amazon CodeWhisperer),.
2.  **Platform Services:** Services like **Amazon SageMaker** for building, training, and deploying ML models.
3.  **Frameworks and Hardware Solutions:** Customized EC2 instances and SDKs for running ML workloads,.

### Amazon SageMaker

Amazon SageMaker is a **managed platform service** that streamlines the entire ML lifecycle—from data preparation to model deployment.

**ML Lifecycle Features:**

- **Prepare Data:** Tools like **Data Wrangler** help import, prepare, transform, and analyze data within SageMaker Studio.
- **Build:** Use Jupyter notebooks in SageMaker Studio to build models using popular frameworks (TensorFlow, PyTorch) or custom code.
- **Train:** Training jobs run on managed infrastructure, abstracting away hardware and resource management.
- **Deploy (Inference):** Supports various deployment methods based on latency, payload size, and real-time needs:
  - **Real-time Inference:** For workloads requiring low latency.
  - **Serverless Inference:** Fully managed, suitable for workloads that can tolerate **cold-start problems**.
  - **Asynchronous Inference:** For large payload sizes (up to 1 GB) with near real-time processing.
  - **Batch Transforms:** For processing entire datasets.

**Additional Key Features:**

- **Clarify:** Detects potential bias and helps **clarify model predictions**.
- **Debugger:** Visualizes model performance and identifies system bottlenecks (e.g., CPU, GPU, I/O).
- **Pipelines:** Automates the ML lifecycle, helping build end-to-end **CI/CD pipelines**.
- **AMT (Automatic Model Tuning):** Runs multiple training jobs to determine the best model version based on hyperparameter values.
- **Ground Truth:** Automates the process of creating high-quality, **labeled datasets**.

### AWS ML Application Services

These are fully managed, customized services for specific ML use cases, minimizing the need for building, deploying, and maintaining custom ML models.

| Service                  | Functionality                                                                                                                        |
| :----------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| **Amazon CodeWhisperer** | AI coding companion that generates code suggestions and flags security issues.                                                       |
| **Amazon Comprehend**    | Gathers insights from unstructured data, including entities, PII, language, and **sentiment analysis** (e.g., for customer reviews). |
| **Amazon Kendra**        | ML-powered search engine that uses natural language processing on structured/unstructured data repositories.                         |
| **Amazon Forecast**      | Provides **accurate time-series forecasts**, automatically selecting suitable ML algorithms.                                         |
| **Amazon Rekognition**   | Image and video analysis service for content search, face identification, and **text extraction from images**.                       |
| **Amazon Transcribe**    | **Speech-to-text conversion** service (e.g., for deriving insights from customer feedback calls),.                                   |

### AWS ML Infrastructure

AWS offers specialized EC2 instances, referred to as **accelerated computing instances**, which include **hardware-based accelerators** (coprocessors like GPUs, FPGAs, AWS Inferentia, and AWS Trainium) to enhance computing power for ML workloads.

- **AWS Trainium:** Optimized for **deep learning training workloads**, offering up to 50% cost-to-train savings. Supports the **AWS Neuron SDK** and integrates with PyTorch/TensorFlow.
- **AWS Inferentia:** Designed for **ML inference applications**, providing high throughput and low latency at a lower cost than general-purpose EC2 instances,. For example, Amazon EC2 Inf1 instances offer 2.3 times higher throughput and up to 70% lower cost per inference than comparable EC2 instances.
