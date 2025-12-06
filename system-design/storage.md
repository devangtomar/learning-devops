## Types of Storage

### Types of Storage

1. **Block Storage** (unstructured data, high-performance apps/databases)

   - **Description:** Data is stored in fixed-size blocks. Each block is addressed and managed independently.
   - **Use cases:** Databases, virtual machines, container volumes, high-IOPS/low-latency applications.
   - **Examples:** Amazon EBS, Google Persistent Disk, Azure Managed Disks.
   - **Notes:** Exposed via iSCSI or similar protocols; supports snapshots and fine-grained backups.

2. **Object Storage** (large-scale unstructured data)

   - **Description:** Data stored as objects (data + metadata + unique ID) and accessed via HTTP APIs. Designed for massive scale and high durability.
   - **Use cases:** Images, videos, logs, backups, static website assets, archival.
   - **Examples:** Amazon S3, Google Cloud Storage, Azure Blob Storage.
   - **Notes:** Optimized for throughput and large sequential reads/writes; not suitable for low-latency random I/O or POSIX semantics. Offers lifecycle policies, versioning, and cheap archival transitions.

3. **File Storage** (structured data and shared files)
   - **Description:** Hierarchical namespace accessed over network file protocols (NFS, SMB) with POSIX semantics where required.
   - **Use cases:** Content management, home directories, shared media repositories, lift-and-shift apps requiring file shares.
   - **Examples:** Amazon EFS, Google Filestore, Azure Files.
   - **Notes:** Good for collaborative workloads, file locking, directory structures; performance and capacity depend on provider and tier.

### How to Choose the Right Storage Type

- **Performance requirements:** Block for high IOPS/low latency; file for moderate-latency shared access; object for throughput/large sequential workloads.
- **Access patterns:** Random small I/O → block. Many large sequential reads/writes → object. Multiple clients sharing files → file.
- **Scalability/capacity:** Object scales virtually infinitely. Block/file have provider-dependent limits.
- **Semantics/consistency:** Need POSIX (rename/locking) → file. Filesystem-on-block devices → block. Object APIs offer read-after-write or eventual consistency depending on provider.
- **Durability/redundancy:** Object often provides highest built-in durability and geo-replication. Block/file durability depends on replication and backups.
- **Cost model:** Object — low per-GB, request/egress charges. Block — charged by provisioned capacity/IOPS on some providers. File — charged per-GB and performance tier.
- **Data management features:** Metadata, lifecycle policies, versioning, archival → object.
- **Protocol compatibility:** Existing NFS/SMB apps → file. S3-compatible apps → object. VMs/DBs needing raw devices → block.
- **Backup/snapshots:** Block and many managed file systems support fast snapshots. Object provides versioning and lifecycle-based retention.
- **Security/compliance:** Compare encryption at rest/in transit, IAM, logging, and audit features.
- **Hybrid/on-prem:** Consider gateway products or managed file services for local protocol compatibility with cloud-backed object stores.

Quick decision guide:

- Database, VM boot/data disk, high-IOPS app → Block storage.
- Large unstructured datasets, backups, static assets → Object storage.
- Shared files, legacy apps expecting NFS/SMB → File storage.
- Often combine types (e.g., object for archival, block for DB, file for shared workloads).

![storage diagram](image.png)

---

## Databases

![databases diagram](image-1.png)

1. **Relational Databases (RDBMS)** — structured data with relationships

   - **Description:** Schema-based tables, SQL for queries and transactions.
   - **Use cases:** Financial systems, CRM, ERP, workloads requiring complex joins and strong consistency.
   - **Examples:** MySQL, PostgreSQL, Oracle, Microsoft SQL Server.
   - **Notes:** Strong ACID guarantees; suited for complex queries and transactional integrity.

2. **NoSQL Databases** — flexible schemas and distributed scale
   - **Description:** Schema-flexible stores optimized for horizontal scalability. Includes document, key-value, column-family, and graph models.
   - **Use cases:** Real-time web apps, big-data pipelines, session stores, content stores.
   - **Examples:** MongoDB (document), Cassandra (column-family), Redis (key-value), Neo4j (graph).
   - **Notes:** Often favor availability and partition tolerance; consistency model varies by product.

### Logical components of a database schema design

- **Tables:** Core units in relational DBs; store rows and columns representing entities and their attributes.
- **Rows:** Records (tuples) representing individual instances; typically identified by a primary key.
- **Columns:** Attributes/fields with defined data types (integer, string, date, etc.).
- **Relationships:** Associations between tables (one-to-one, one-to-many, many-to-many) implemented via keys and join tables when needed.
- **Keys:** Primary keys uniquely identify rows. Foreign keys reference primary keys in other tables to enforce relationships and referential integrity.
- **Indexes:** Data structures (B-tree, hash, etc.) that speed lookups and queries on indexed columns.
- **Constraints:** Rules to enforce data integrity (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL).
- **Views:** Virtual tables defined by queries that present or restrict data without duplicating underlying data; useful for security and abstraction.
- **Transactions:** Group multiple operations into a single atomic unit. Governed by ACID properties (Atomicity, Consistency, Isolation, Durability) in relational systems.

![schema diagram](image-2.png)

## Optimizing relational database performance

- **Indexing:** Create indexes on frequently queried columns to speed up lookups. Use composite indexes for multi-column queries. Monitor and remove unused indexes to reduce overhead.
- **Query optimization:** Analyze and optimize SQL queries using EXPLAIN plans. Avoid SELECT \*; use WHERE clauses to limit result sets. Refactor complex joins and subqueries.
- **Normalization:** Design schema to eliminate redundancy and ensure data integrity. Use normal forms (1NF, 2NF, 3NF) appropriately, but denormalize when read performance is critical.
- **Denormalization:** In some cases, duplicate data across tables to reduce joins and improve read performance, especially in read-heavy applications.
- **Caching:** Implement caching layers (e.g., Redis, Memcached) to store frequently accessed data in memory, reducing database load and latency.
- **Connection pooling:** Use connection pools to manage database connections efficiently, reducing overhead from establishing connections.
- **Partitioning/Sharding:** Split large tables into smaller, manageable pieces (horizontal partitioning) or distribute data across multiple database instances (sharding) to improve performance and scalability.
- **Database tuning:** Regularly monitor performance metrics and adjust database configuration parameters (e.g., buffer sizes, cache settings) for optimal performance.
- **Load balancing:** Distribute read and write operations across multiple database replicas to improve throughput and reduce latency.
- **Regular maintenance:** Perform routine tasks such as vacuuming, analyzing, and rebuilding indexes to maintain database health and performance.
- **Use of stored procedures:** Encapsulate complex logic within the database to reduce network overhead and improve performance.
- **Monitoring and alerting:** Implement monitoring tools to track database performance metrics and set up alerts for anomalies or performance degradation.

## Scaling Relational Databases

### Partitioning

- **Description:** Partitioning divides a large table into smaller, more manageable parts (partitions). Each row belongs to exactly one partition; partitions can be queried independently or together via a coordinator.
- **Types:**
  - **Vertical partitioning:** Split by columns (e.g., customer core data vs. contact data).
  - **Horizontal partitioning:** Split by rows (e.g., ranges of customer IDs, zip codes).
- **Horizontal approaches:**
  - **Hash partitioning:** Compute a hash of the partition key and distribute rows evenly across partitions — good for uniform distribution.
  - **Range partitioning:** Assign contiguous key ranges to partitions — good for range queries but can cause hot partitions.
- **Benefits:** Improves query performance, enables targeted maintenance, reduces index sizes, and can improve cache locality.
- **Drawbacks:** Adds complexity to query routing, rebalancing partitions can be costly, and poorly chosen partition keys cause hotspots.

![partitioning diagram](image-3.png)

---

### Sharding

- **Description:** Sharding distributes the dataset across multiple database servers (shards). Each shard holds a subset of the data and serves queries for that subset.
- **Types:**
  - **Vertical sharding:** Split tables or functionality across different servers.
  - **Horizontal sharding:** Distribute rows across shards using a sharding key.
- **Horizontal approaches:** hash-based, range-based, and round-robin.
- **Benefits:** Enables horizontal scale of storage and write throughput, reduces per-shard index sizes, improves cache effectiveness, and isolates failures (one shard failure doesn't bring down others).
- **Drawbacks:** Requires application awareness of shard layout (or a routing layer), complex cross-shard joins and transactions, potential data skew/hotspots, non-trivial rebalancing, and increased operational complexity and hardware requirements.
- **Mitigations:** Choose a shard key that balances load (consistent hashing can reduce movement) and use middleware or routing/coordinator layers to simplify application logic.

![sharding diagram](image-4.png)

---

### Database Replication

- **Description:** Replication copies data from one database node to others (replicas). Replication improves availability, read scaling, latency for geo-distributed users, and supports disaster recovery.
- **Key benefits:**
  - **High availability:** Failover to replicas if a primary node fails.
  - **Load distribution:** Offload read traffic to replicas.
  - **Reduced latency:** Place read copies closer to users.
  - **Disaster recovery:** Use replicas for backups and recovery.
  - **Scalability:** Add replicas to handle increased read loads.
- **Replication topologies:**
  - **Single-leader (primary-replica):** One leader handles writes; replicas serve reads. Simple to reason about; common for read-scaled workloads.
  - **Multi-leader (active-active):** Multiple nodes accept writes and replicate changes to each other. Useful for multi-region writes and higher write availability but requires conflict resolution.
  - **Leaderless/Quorum-based:** Writes/reads are coordinated across a set of nodes with quorum guarantees (used by some distributed stores).
- **Considerations:** Choose synchronous vs asynchronous replication based on durability/latency trade-offs; plan for conflict resolution (multi-leader), failover automation, and replication monitoring. Ensure backups, replication topology testing, and consistent configuration across nodes.

![replication diagram](image-5.png)

## Open Source Relational Database Systems

- MySQL
- PostgreSQL
- MariaDB
- SQLite
- CockroachDB
- TimescaleDB
- Percona Server for MySQL
