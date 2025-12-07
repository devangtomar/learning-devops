# Chapter 10. AWS Storage Services

This chapter focuses on AWS-specific storage services, ranging from traditional options like block storage to various database solutions. The selection of these services should align with business and technical requirements, such as those for an online restaurant like Cafe Delhi Heights.

## Cloud Storage on AWS

AWS provides multiple cloud storage options: Amazon Elastic Block Store (EBS) for block storage, Amazon Elastic File System (EFS) for file storage, and Amazon Simple Storage Service (S3) for object storage.

### Amazon Elastic Block Store (EBS)

EBS is a **block storage solution** that functions like a network-attached physical hard drive associated with an Amazon Elastic Compute Cloud (EC2) instance.

- **Lifecycle and Flexibility:** An EBS volume's lifecycle is independent of its attached EC2 instance. It is flexible, allowing configuration modifications on live production workloads, such as increasing size dynamically, changing provisioned IOPS capacity, or altering the volume type.
- **Use Cases:** Preferred for workloads requiring frequent disk access, such as creating custom databases or OS boot volumes.
- **Availability:** EBS volumes operate at the **Availability Zone (AZ) level** (cannot attach across AZs). They are automatically replicated within an AZ to prevent data loss. Point-in-time snapshots enable replication and high availability across AZs or regions.
- **Multi-Attach:** This feature allows a single provisioned-IOPS SSD volume to be attached to a maximum of 16 Nitro-based EC2 instances (for Linux applications).
- **Volume Types:**
  - **Solid-State Drives (SSDs):** Optimized for transactional workloads (small I/O size), including general-purpose SSDs and provisioned-IOPS SSDs.
  - **Hard Disk Drives (HDDs):** Optimized for large streaming workloads (throughput focus), including throughput-optimized SSDs and cold HDDs.
  - **Magnetic Disks:** Suitable for smaller workloads where performance is not a key factor.
- **Instance Store:** This is a separate, non-flexible solution for temporary block storage directly attached to an instance, suitable for caching or device buffers, but data is wiped upon instance failure or state change (stop/hibernate/terminate).

### Amazon Elastic File System (EFS)

EFS is a **shared file system** that allows storage sharing across multiple servers within a region or even at an on-premises data center.

- **Nature:** It is a fully managed, serverless solution that supports all AWS compute platforms (EC2, ECS, Lambda). Customers do not need to preconfigure storage space, as pricing is based on actual usage.
- **Use Cases:** Used for big data analytics, ML workloads, and content management.
- **Storage Classes:**
  - **Standard and Standard Infrequent Access (Standard IA):** Provide the highest availability across AZs in a region. Standard is for frequent access, while Standard IA is cost-optimal for infrequent access (though it has higher latency for first byte read/write).
  - **One Zone and One Zone Infrequent Access (One Zone IA):** Ensure high availability within a **single AZ**. These are relatively cheaper, but data durability relies on external services like AWS Backup.
- **Amazon FSx:** A managed service for running other file systems, including FSx for Windows File Server (for end-user file stores, accessible via SMB) and FSx for Lustre (high-performance computing/ML workloads, linkable with S3).

### Amazon Simple Storage Service (S3)

S3 is an **unlimited object storage solution** that allows users to access files directly over the public internet or private AWS network without requiring an intermediate server.

- **Structure:** Data is stored as **objects** within unique **buckets**. An object is identified by a unique key name within the bucket.
- **Versioning:** S3 supports storing multiple versions of the same object, useful for recovery after application failure.
- **Storage Classes:** Selection is based on required access type and redundancy.
  - **Frequently Accessed:** S3 Standard (default).
  - **Infrequently Accessed (IA):** Standard IA (multi-AZ redundancy) and One Zone IA (single-AZ, cheaper, less resilient).
  - **Archived Objects:**
    - S3 Glacier Instant Retrieval: For rarely accessed data requiring millisecond retrieval.
    - S3 Glacier Flexible Retrieval: Data accessibility within minutes (1–5 minutes); 90-day minimum storage duration.
    - S3 Glacier Deep Dive: Least costly; default retrieval time is 12 hours (bulk retrieval 48 hours); 180-day minimum storage duration.
- **Lifecycle Management:**
  - **Lifecycle Configurations:** Rules defining object movement (**Transition actions**) to another storage class (e.g., Standard to Standard IA) or object deletion (**Expiration actions**).
  - **Intelligent Tiering:** Automatically moves objects between storage classes (Frequent Access, Infrequent Access, Archive Instant Access, etc.) based on access patterns without operational overhead.
- **Data Security:** S3 offers multiple mechanisms for securing data and configuring access permissions.
  - **Encryption:** Objects are encrypted by default with server-side encryption (SSE-S3), with options for AWS Key Management Service (SSE-KMS) or client-side encryption.
  - **Object Lock:** Enables a Write Once, Read Many (WORM) model on versioned buckets, useful for regulatory compliance by preventing objects from being overwritten or deleted for a retention period.
  - **Access Control:** Access is managed via IAM policies, bucket policies (up to 20 KB limit), or Access Control Lists (ACLs), which are disabled by default. The **Block Public Access** option manages centralized control on public access.
  - **Amazon Macie:** Identifies and secures sensitive data stored in S3 buckets, such as credit card numbers.

## AWS Databases

AWS offers managed database services, such as RDS, DynamoDB, and ElastiCache, minimizing operational overhead and providing scalability.

### Amazon RDS and Amazon Aurora (Relational)

**Amazon RDS** manages relational database engines (MySQL, PostgreSQL, MariaDB, Oracle, Microsoft SQL Server, and Amazon Aurora), removing the maintenance overhead of managing servers, backups, and storage.

- **Configuration:** Customers configure engine type, instance class (determining compute/memory capacity), storage (type and allocation), and availability/durability (Multi-AZ deployment for high availability).
- **Amazon Aurora:** A proprietary database engine compatible with MySQL and PostgreSQL, offering up to five times faster performance than MySQL.
  - **Durability and Scaling:** Automatically scales storage up to 128 TB (or 64 TB for certain versions). It stores six copies of data across three AZs and continuously backs up to S3.
  - **Read Replicas:** An Aurora DB cluster supports up to 15 read replicas, which distribute read workload and ensure high availability through promotion if the writer instance fails.
  - **Aurora Serverless:** Uses Aurora Capacity Units (ACUs) instead of fixed instance types, ideal for unpredictable workloads.
  - **Aurora DSQL:** A distributed relational database (PostgreSQL compatible) designed for transactional workloads requiring unlimited compute and storage scaling with ACID compliance.

### Amazon DynamoDB (Key-Value)

DynamoDB is a **fully managed, schemaless key-value database** designed for single-digit millisecond latency at any scale.

- **Key Structure:** The primary key is the **Partition Key** or a combination of **Partition Key and Sort Key** (Range Key).
  - The Partition Key determines the physical partition where data is stored using an internal hash function.
  - The Sort Key orders items within a partition.
- **Architecture:** A Request Router (RR) routes requests to partitions. Write operations (PUT) go to the leader node, while reads (GET) can be served by the leader or followers, depending on the required consistency.
- **Capacity Modes:**
  - **Provisioned:** Customer configures specific RCUs/WCUs for predictable traffic.
  - **Autoscaling:** Automatically adjusts RCUs/WCUs within defined limits for varying workloads.
  - **On-Demand:** Serverless mode; DynamoDB manages capacity; preferred for unpredictable traffic.
- **Indexes:**
  - **Local Secondary Index (LSI):** Shares the base table's partition key but has a different sort key. Scoped to the partition (10 GB data limit) and shares throughput capacity. Supports strong/eventual consistency.
  - **Global Secondary Index (GSI):** Allows different partition and sort keys from the base table. Queries span partitions (no size limits) and have independent throughput settings. **Only supports eventual consistency**.
- **Partition Limits:** Partitions have hard limits: 3,000 RCUs, 1,000 WCUs/sec, and 10 GB of storage. A partition exceeding these limits is a **hot partition**.

### Amazon DocumentDB (Document)

DocumentDB is a managed document database **compatible with MongoDB** that stores data as JSON-like documents.

- **Features:** Supports powerful ad hoc queries and transactions (on multiple documents). It requires specifying instance class and number of instances (three recommended for production HA).
- **Use Cases:** Suitable for content management, user-profile maintenance, and real-time big data. Migration from MongoDB is supported via DMS.

### Amazon Neptune (Graph)

Neptune is a **fully managed graph database service** optimized to store and map billions of relationships.

- **Query Languages:** Supports Apache TinkerPop Gremlin or openCypher (for property graphs) and SPARQL (for RDF graphs).
- **Compute:** Supports one writer instance and up to 15 read replicas across multiple AZs. Writer instances scale vertically; read replicas scale horizontally/vertically. Failover promotes a read replica to writer. A serverless configuration is available.
- **Storage:** Stores six data copies across three AZs; scales independently and automatically up to 128 TB.
- **Access/Caching:** Provides separate writer and reader endpoints. It supports multiple caching types, including an in-memory **Buffer cache** and a disk-based **Lookup cache** (on NVMe SSD) for repetitive queries.

### Amazon ElastiCache (In-Memory)

ElastiCache is a managed service for distributed caching using the **Redis** and **Memcached** engines.

- **Redis:** Supports sorted sets, persistence (can be used as a standalone database), advanced data structures, and Pub/Sub messaging. It is primarily a single-threaded process.
  - **Scaling:** Supports horizontal scaling via **Cluster mode enabled** (up to 500 nodes) and replication via Multi-AZ deployment.
  - **Data Tiering:** Available for cost optimization on specific instance families, moving infrequent data to NVMe SSD storage.
- **Memcached:** A simple, multithreaded key-value solution that utilizes multiple CPU cores efficiently. It is a pure caching solution without strong persistence support.
- **Security:** Redis offers encryption capabilities and is compliant with standards like PCI DSS. Memcached lacks strong authentication/encryption and should be deployed in private subnets.

### Amazon DynamoDB Accelerator (DAX)

DAX is a custom, managed in-memory cache **specifically for DynamoDB** designed to improve read performance to microseconds.

- **Operation:** A DAX client running on the application server redirects eventually consistent read API calls (GetItem, Query, Scan) to the DAX cluster. For write APIs, the operation is successful only if the write succeeds in both DynamoDB and the DAX cluster.

### Other AWS Database Services

- **Amazon OpenSearch:** A managed service derived from Elasticsearch, used for full-text search, logs/analytics, and ingestion pipelines. It recommends an odd number (minimum three) of cluster manager nodes for production stability.
- **Amazon Timestream:** A fully managed, serverless database for **time-series data**. Data is immutable, and records require timestamps. It supports two storage tiers: in-memory (low latency) and magnetic disk (analytical queries).
- **Amazon Keyspaces:** A highly scalable, serverless, managed wide-column database compatible with **Apache Cassandra**. It removes the overhead of cluster management (e.g., JVM tuning, patching). It offers capacity modes similar to DynamoDB: provisioned capacity with autoscaling and on demand.

## Summary of Storage Service Use Case Mapping

The chapter concludes with a table demonstrating how specific requirements map to AWS storage services:

| Requirement                                                          | Storage Service                                                         |
| :------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| Store customer's profile and access details                          | Amazon RDS, Amazon Aurora, Amazon ElastiCache (as cache)                |
| Store food information (menu items)                                  | Amazon DynamoDB, Amazon DocumentDB, Amazon Keyspaces, Amazon OpenSearch |
| Store different kinds of media (images, reviews)                     | Amazon S3                                                               |
| Big data analytics                                                   | Amazon S3, Amazon EFS, Amazon DynamoDB                                  |
| Create food communities/social circles                               | Amazon Neptune                                                          |
| Search for food items based on identifiers (name, location, ratings) | Amazon OpenSearch                                                       |
| Application logs and metrics archival                                | Amazon S3, Amazon OpenSearch                                            |
