# Load Balancing — Approaches & Techniques (Notes)

## 1. Why Load Balancing?

Horizontal/vertical scaling alone is not enough for highly available systems.  
Load balancing distributes inbound traffic across a server pool to ensure:

- Scalability
- High availability
- Fault tolerance
- Optimized resource utilization
- Consistent performance and low latency

---

## 2. Key Networking Components

### **Forward Proxy**

- Sits _in front of the client_
- Represents client to external servers
- **Use cases:** corporate access policies, content filtering, anonymity, outbound caching

### **Reverse Proxy**

- Sits _in front of servers_
- Represents servers to clients
- **Use cases:** request routing, TLS termination, caching, compression, WAF

### **Load Balancer**

- Distributes traffic across backend servers
- Performs health checks
- **L4 (Transport):** TCP/UDP routing
- **L7 (Application):** HTTP/HTTPS routing based on headers, path, cookies
- Algorithms: RR, weighted RR, least connections, least response time, consistent hashing

### **API Gateway**

- Specialized reverse proxy for APIs
- Features: auth, rate limiting, transformations, versioning, observability
- Typical “front-door” for microservices

---

## 3. Quick Comparison

| Component     | Sits In Front Of | Hides                 | Main Purpose                             |
| ------------- | ---------------- | --------------------- | ---------------------------------------- |
| Forward Proxy | Client           | Client identity       | Control/anonymize outbound traffic       |
| Reverse Proxy | Server(s)        | Server topology       | Protect backend & route traffic          |
| Load Balancer | Server pool      | Server identities     | Distribute traffic & ensure availability |
| API Gateway   | API services     | Microservice topology | Manage, secure & orchestrate API calls   |

---

## 4. Architecture Mental Model

```

CLIENT → Forward Proxy → Internet
CLIENT → Reverse Proxy / Load Balancer → Server Pool
CLIENT → API Gateway → Microservices

```

---

## 5. Benefits of Load Balancing

- **Scalability:** easy to add/remove servers; integrates with autoscaling
- **High availability:** routes around failures/unhealthy nodes
- **Performance:** avoids hotspots; improves latency/throughput
- **Fault tolerance:** avoids single points of failure
- **Efficient resource usage:** balances workload across servers

---

## 6. Global vs Local Load Balancing

### **Global Server Load Balancing (GSLB)**

Distributes traffic across regions/data centers.  
Approaches:

- **ADC-based:** uses health and capacity of data centers
- **DNS-based:** directs users to nearest/healthiest region
- **CDN-based:** CDN stores/distributes static content globally

### **Local Load Balancing**

Within a single data center/region.

- Uses a **VIP** (virtual IP) shared across machines
- LB operates between:
  - Clients → Web tier
  - Web → App tier
  - App → DB tier (read-heavy workloads)

---

## 7. Load Balancing Algorithms

### **Static Algorithms**

- Do **not** consider runtime server load
- Easier but less adaptive  
  Includes:
- **Round Robin (RR)**
- **Weighted RR**
- **Hash-based** (IP hash, URL hash)

### **Dynamic Algorithms**

- Reactive to current server health/load  
  Includes:
- **Least connections**
- **Least response time**
- **Least loaded** (CPU/memory aware)

---

## 8. Session Persistence (Stateful vs Stateless LBs)

### **Stateful Load Balancers**

Maintain session info; ensure session stickiness.  
Methods:

- **Cookie-based affinity**
- **Source IP affinity**

Pros:

- Required for stateful workflows (ecommerce cart, banking)

Cons:

- More memory/CPU usage
- Harder to scale

### **Stateless Load Balancers**

Do not store session info; every request is independent.

Pros:

- Highly scalable
- Simpler and faster

Recommendation:

- Prefer stateless LBs + external session store (e.g., Redis)

---

## 9. Types of Load Balancers (Functionality-Based)

### **DNS Load Balancers (Tier 0)**

Map domain → different IPs  
Examples: Route 53, Azure Traffic Manager

### **ECMP Routers (Tier 1)**

Network-layer multipath routing

- Hashes packet headers
- Balances across equal-cost paths

Examples: Cisco Nexus, Juniper routers

### **Network Load Balancers (L4)**

Operate at TCP/UDP (transport layer).  
Modes:

- **DSR (Direct Server Return)**
- **NAT mode**

Pros: very fast, low latency  
Examples: AWS NLB, Azure LB, nginx TCP/UDP

### **Application Load Balancers (L7)**

Operate on HTTP/HTTPS; terminate connections.  
Features:

- Header/path-based routing
- Cookie/session persistence
- SSL/TLS termination (offloading)

Examples: AWS ALB, Azure App Gateway, nginx HTTP

---

## 10. Types Based on Deployment

### **Hardware Load Balancers**

- Physical appliances
- High performance; expensive
- Vendor-locked; limited flexibility

Examples: F5 BIG-IP, Citrix NetScaler

### **Software Load Balancers**

- Run on commodity servers/VMs
- Highly scalable and flexible
- Great for cloud environments

Examples: HAProxy, nginx

**LBaaS:** fully managed LB services from cloud vendors.

---

## 11. Nginx Overview

Nginx is a high-performance:

- Web server
- Reverse proxy
- Load balancer (L4/L7)

Used widely for:

- HTTP routing
- SSL termination
- Caching
- High-throughput load balancing
