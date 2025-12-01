# AWS Route 53 — Domain Name System (DNS) Service

Amazon Route 53 provides:

- Domain registration and DNS hosting
- High availability, low-latency DNS resolution via a global network of edge locations
- Traffic management (routing policies) and health checks for failover and load distribution
- Private hosted zones for VPC-scoped DNS and integration with other AWS services (ELB, CloudFront, S3, API Gateway)

## Key concepts

- **Hosted Zone** — a container for DNS records for a domain
- **Record Set** — DNS records (A, AAAA, CNAME, MX, TXT, SRV, NS, etc.). Alias records map directly to AWS resources (ELB, CloudFront) without incurring DNS query charges
- **TTL (time to live)** — how long resolvers cache records
- **Health Checks** — monitor endpoints and trigger failover/routing changes
- **Routing Policies** — simple, weighted, latency-based, failover, geolocation, geoproximity, and multi-value answer

## Common use cases

- Host a public website with DNS pointing to an ELB, CloudFront distribution, or S3 static site
- Implement active/passive or weighted failover across regions
- Provide internal DNS resolution using private hosted zones for one or more VPCs
- Hybrid DNS using Route 53 Resolver endpoints for on-premises ↔ AWS name resolution

## Quick start (high level)

1. Create/transfer or register your domain.
2. Create a hosted zone for the domain.
3. Add record sets (A/AAAA, CNAME, MX, TXT) or Alias records for AWS targets.
4. Update registrar name servers to Route 53’s NS records if Route 53 is the DNS provider.
5. (Optional) Add health checks and configure a routing policy for resilience.

## Minimal AWS CLI examples

Create a hosted zone:

```bash
aws route53 create-hosted-zone --name example.com --caller-reference "$(date +%s)"
```

Change a record set (supply JSON file to change-resource-record-sets):

```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456ABCDEFG \
    --change-batch file://changes.json
```

## Best practices

- Use Alias records for AWS targets to avoid extra DNS lookups and simplify failover
- Keep TTLs reasonable for dynamic failover (lower for rapid changes, higher for cache efficiency)
- Use health checks and failover or weighted routing to improve availability
- Restrict public exposure with private hosted zones for internal resources; use resolver endpoints for hybrid networks
- Monitor DNS metrics and logs with CloudWatch and Route 53 query logging for troubleshooting and security

## Further reading

Refer to the AWS Route 53 documentation for detailed examples, supported record types, and advanced traffic policies.
