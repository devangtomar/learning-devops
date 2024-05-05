## Important

### Differences..

- **API Gateway**: Manages application-level traffic (HTTP/HTTPS), acting as a front door for APIs to access backend services.

- **NAT Gateway**: Allows instances in a private subnet to send outbound traffic to the internet or other AWS services but prevents inbound traffic.

- **Internet Gateway**: Enables communication between instances in a VPC and the internet, handling both inbound and outbound traffic.

- **Ingress**: Refers to incoming traffic to a network or application, typically controlled by rules or policies for security and routing.

- **Egress**: Refers to outgoing traffic from a network or application, also controlled by rules or policies to manage access to external resources.

### Differences b/w NACL vs security group

NACL (Network Access Control List) and Security Groups serve as layers of security in cloud environments, such as AWS, but they operate at different levels and have distinct characteristics:

- **Security Group**:

  - **Operates at the instance level** or the virtual network interface.
  - **Stateful**: This means that if an inbound traffic is allowed, the outbound traffic for that session is automatically allowed, and vice versa.
  - **Supports allow rules only**: You can specify only allow rules. If there's no rule that explicitly allows a type of traffic, it's automatically denied.
  - **Evaluates all rules before deciding**: The system evaluates all the rules in a security group before allowing traffic.

- **NACL (Network Access Control List)**:
  - **Operates at the subnet level**, affecting all instances within the subnet.
  - **Stateless**: This means that inbound and outbound traffic is treated separately. An allowed inbound traffic does not automatically allow the outbound response. Both directions must be explicitly allowed.
  - **Supports both allow and deny rules**: This provides a more granular control over the traffic.
  - **Processes rules in order, stopping at the first match**: Rules are evaluated in numerical order, and as soon as a rule matches the traffic, it's either allowed or denied based on that rule. This means the order of the rules can affect the traffic flow.

In essence, Security Groups are best for setting granular permissions on individual instances or resources, while NACLs provide a broader layer of security at the subnet level, offering an additional layer of defense. They are often used together to implement a robust security posture in cloud environments.
