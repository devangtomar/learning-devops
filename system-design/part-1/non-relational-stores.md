## Why Non-Relational Stores?

Relational databases have traditionally been the cornerstone of
data management, providing a structured, standardized
approach to organizing and retrieving information. As the
digital universe continues to expand exponentially, though,
traditional relational models face inherent limitations when
confronted with the demands of modern web applications, realtime analytics, and large-scale distributed systems.
Nonrelational databases break away from the rigid constraints
of the relational paradigm and introduce novel data models and
storage mechanisms that challenge the status quo. These
databases prioritize scalability, fault tolerance, and low-latency
access, enabling organizations to effectively handle massive
volumes of data and support dynamic, rapidly evolving data
requirements.

AWS offers a range of nonrelational database services, such as Amazon DynamoDB,
Amazon DocumentDB, Amazon Neptune, Amazon ElastiCache, Amazon OpenSearch,
Amazon Keyspaces, and more, to meet customer requirements for different business
use cases.

### Nonrelational Database Concepts

Schema Flexibility
Unlike relational databases that enforce a fixed schema,
nonrelational databases allow for dynamic and flexible schema
designs. This means that data can be stored without the need to
predefine a strict structure, making it easier to accommodate
varying data formats and evolving application requirements.

Data Models
Nonrelational databases support various data models, each
optimized for specific use cases. The most common data models
include:
Document stores

## Why Non-Relational Stores?

Relational databases provide structured, schema-based storage and strong ACID guarantees. Non-relational (NoSQL) databases trade some of those constraints for greater horizontal scalability, flexible schemas, and low-latency access patterns needed by modern web-scale applications, real-time analytics, and distributed systems.

Cloud vendors provide managed NoSQL services to cover common use cases — for example: Amazon DynamoDB, Amazon DocumentDB, Amazon Neptune, Amazon ElastiCache, Amazon OpenSearch, and Amazon Keyspaces.

### Key Concepts

- **Schema flexibility:** Stores can accept documents/records with varying fields and nested structures without a predefined schema.
- **Data models:** Common models include key-value, document, column-family, and graph.
- **Scalability:** Designed to scale horizontally via sharding/partitioning and replication.
- **Availability & fault tolerance:** Built to handle node failures and network partitions with differing consistency trade-offs.
- **Consistency model:** Many systems prefer BASE (Basically Available, Soft state, Eventually consistent) over strict ACID for higher availability.

## Data Models Overview

- **Key-value stores:** Simple mapping from key → value. Excellent for caching, sessions, and very fast lookups.
- **Document stores:** JSON/BSON documents grouped in collections; support nested data, indexing, and rich queries/aggregations.
- **Column-family stores:** Wide-column tables optimized for analytical workloads and large-scale time-series data.
- **Graph databases:** Model entities and relationships; optimized for traversals and relationship-heavy queries.

## Key-Value Databases

Key-value stores provide the simplest NoSQL model: a unique key maps to an opaque value. They are optimized for very fast reads/writes by key and usually offer a schemaless design.

- **Data model:** Items consist of a primary key and an associated value (string, binary, or structured blob such as JSON).
- **Indexing:** Typically limited to the primary key; secondary indexing is either absent or limited.
- **Partitioning:** A partition (shard) key determines how items are distributed across nodes — choose it to avoid hotspots.

### Keys explained

- **Primary key:** Uniquely identifies an item.
- **Partition key:** Controls distribution across shards/nodes.
- **Sort (range) key:** Optional; enables ordered/range queries within a partition.

### Common operations

- **GetItem:** Retrieve an item by primary key.
- **PutItem:** Insert or replace an item.
- **UpdateItem:** Modify attributes of an existing item (or create if missing).
- **DeleteItem:** Remove an item by key.

## Document Databases

Document stores keep self-contained JSON/BSON documents in collections. Documents can contain nested structures and arrays, making them a good fit for evolving or hierarchical data.

- **Collections:** Logical containers for related documents (similar to tables).
- **Documents:** Individual JSON-like records; each document can have a different set of fields.
- **Projection:** Return only required fields to reduce data transfer.
- **Indexing:** Secondary indexes improve query performance on fields other than the primary key.

### Operations & features

- **Insert / Update / Delete / Query:** CRUD operations plus expressive query languages and aggregation pipelines.
- **Aggregation:** Grouping, sorting, transformations and analytics inside the database.
- **Indexes:** Support for compound and sparse indexes; improve query latency.

## Scalability, Replication, and HA

- **Horizontal scaling:** Sharding/partitioning spreads data and traffic across nodes.
- **Replication topologies:** Primary-replica (single-leader), multi-leader (active-active), and leaderless/quorum-based approaches exist with different trade-offs.
- **Consistency vs latency:** Synchronous replication increases durability but adds latency; asynchronous replication favors availability.

## When to use NoSQL vs RDBMS

- **Use NoSQL when:** Schema flexibility, massive horizontal scale, or specialized access patterns (key-value lookups, document queries, graph traversals) are primary requirements.
- **Use RDBMS when:** Strong ACID transactions, complex joins, and relational integrity are required.

## Summary

Non-relational stores provide a spectrum of data models and trade-offs. Choose based on access patterns, consistency needs, scaling requirements, and operational complexity.

![diagram placeholder](image-6.png)

## Types of Non-Relational Databases

Non-relational databases can be broadly categorized into several types based on their data models and use cases:

1. **Key-Value Stores:** These databases store data as a collection of key-value pairs, where each key is unique and maps to a specific value. They are optimized for fast read and write operations and are ideal for caching, session management, and real-time applications. Examples include Redis and Amazon DynamoDB.
2. **Document Stores:** Document databases store data in the form of documents, typically using formats like JSON or BSON. Each document can have a different structure, allowing for flexibility in data representation. They are well-suited for content management systems, e-commerce platforms, and applications with evolving data schemas. Examples include MongoDB and Couchbase.
3. **Column-Family Stores:** These databases organize data into column families, which are groups of related columns. This model is particularly effective for handling large volumes of data and is commonly used in big data and analytical applications. Examples include Apache Cassandra and HBase.
4. **Graph Databases:** Graph databases are designed to represent and store data in terms of nodes, edges, and properties. They excel at managing complex relationships and are ideal for social networks, recommendation engines, and fraud detection systems. Examples include Neo4j and Amazon Neptune.

As we conclude our exploration, the nonrelational landscape is diverse: key-value stores for ultra-fast lookups, column-family stores for analytical workloads, document stores for flexible schemas, and graph databases for relationship-heavy queries. Other specialised systems include time-series (InfluxDB), in-memory (Redis), search (Elasticsearch), vector (Milvus), geospatial, and ledger databases. Choose based on access patterns, consistency needs, and operational constraints.

## Other database types

- **Time-series:** Optimized for timestamped data (e.g., InfluxDB).
- **In-memory:** Extremely low latency (e.g., Redis).
- **Search / Text index:** Full-text and analytics (e.g., Elasticsearch).
- **Vector DBs:** Similarity search for embeddings (e.g., Milvus).
- **Geospatial / Ledger:** Domain-specific feature sets and guarantees.

## Relational vs Nonrelational (quick comparison)

| Property             | Relational store                         | Nonrelational store                                          |
| -------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| Data model           | Strict schema: tables and columns.       | Schemaless: key-value, JSON documents, wide-columns, graphs. |
| Hierarchical storage | Poor fit for nested/hierarchical data.   | Good fit for hierarchical or interconnected data.            |
| Scalability          | Vertical scaling (scale-up).             | Horizontal scaling (sharding/partitioning).                  |
| Joins                | Efficient for complex multi-table joins. | Cross-shard joins are expensive; often avoided.              |
| Consistency (CAP)    | Typically ACID (strong consistency).     | Often BASE / tunable consistency (eventual by default).      |

![comparison diagram](image-7.png)
