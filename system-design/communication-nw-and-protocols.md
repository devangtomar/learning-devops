# Chapter 6. Communication Networks and Protocols

## Communication Overview

Communication is the simple exchange of words and information. For machines to communicate over the internet, they adhere to specific rules known as protocols. This chapter aims to clarify concepts like TCP, XMPP, WebSockets, WebRTC, HTTP, GraphQL, and REST, and define suitable scenarios for their use.

## Communication Models and Protocols

### OSI Model

The Open Systems Interconnection (OSI) model is a seven-layered reference model where each layer performs a specific job for network communication.

| Layer Number | Layer Name               | Layer Function                                                                                                                                                                                                                                             |
| :----------- | :----------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Layer 7**  | **Application layer**    | Has direct access to user data via protocols (HTTP, SMTP, SSH) and helps with service advertisement.                                                                                                                                                       |
| **Layer 6**  | **Presentation layer**   | Responsible for formatting, encryption/decryption, and compression (reducing data footprint).                                                                                                                                                              |
| **Layer 5**  | **Session layer**        | Manages the session lifecycle: initiation, maintenance, and termination.                                                                                                                                                                                   |
| **Layer 4**  | **Transportation layer** | Responsible for data transport (TCP and UDP). Manages data buffering, error control, and windowing (defining optimal speed and data amount before expecting an acknowledgment). Dropping extra data when the buffer queue is full is called **tail drop**. |
| **Layer 3**  | **Network layer**        | Responsible for data transfer between networks using logical addressing (IP addresses). Data from L4 is broken into **data packets**.                                                                                                                      |
| **Layer 2**  | **Data link layer**      | Transfers data between devices in the form of **frames**. Consists of **Medium Access Control (MAC)** for physical addressing and **Logical Link Control (LLC)** for flow/error control within the same network.                                           |
| **Layer 1**  | **Physical layer**       | Converts data frames to bit streams (ones and zeros). Involves physical devices like cables and switches.                                                                                                                                                  |

### TCP/IP Model

The TCP/IP model, or internet protocol suite (including TCP, IP, and UDP), is commonly used in practice, unlike the OSI model which serves as a reference. It combines multiple OSI layers.

| OSI Model Layer                    | TCP/IP Model Layer   | TCP/IP Protocol Examples |
| :--------------------------------- | :------------------- | :----------------------- |
| Application, presentation, session | **Application**      | SMTP, HTTP               |
| Transport                          | **Transport**        | TCP, UDP                 |
| Network                            | **Internet**         | IP, ICMP                 |
| Data link                          | **Data link**        | IEEE 802.2               |
| Physical                           | **Physical network** | Ethernet                 |

## Network Layer Protocols

- **Internet Protocol (IP):** A set of rules for delivering **data packets** from a source IP address to a destination IP address. IP addresses uniquely identify devices. Data is often broken into chunks (**fragmentation**).
  - The maximum packet size that can be transmitted is the **maximum transmission unit (MTU)** (1,500 bytes for Ethernet).
  - An IP packet contains an **IP header** (source/destination IP, TTL) and a **payload** (IP datagrams—the actual data).
- **Internet Control Message Protocol (ICMP):** Used for network diagnostics and error mechanisms (e.g., used by the `ping` command).

## Transport Layer Protocols

### Transmission Control Protocol (TCP)

TCP is a transport layer protocol offering **reliable communication** with the ability to retransmit data upon packet loss.

- **Connection Initiation:** Uses a **three-way handshake** process to agree to send and accept data.
- **TCP Header:** Includes source/destination port numbers, a **sequence number** (data sent), an **acknowledgment number** (ACK, confirmation and request for next segment), and **window** (receiver's accepted data limit).
- **Congestion Control:** Manages data transfer speed.
  - **Slow start:** Data transfer starts small (one segment) and window size increases exponentially with each ACK.
  - **Congestion avoidance:** Kicks in if congestion is detected (e.g., timeout or duplicate ACKs); halves the congestion window size or resets it.
- **Performance:** Deploying applications closer reduces **round trip time (RTT)**, helping the sender adjust the congestion window quickly.
- **Ports:** Virtual points managed by the OS defining entry/exit from a software application.
  - **Well-known ports (0–1023):** Used by system processes (e.g., Port 80 for HTTP, Port 22 for SSH).
  - **Registered ports (1024–49151):** Used by user processes.
  - **Ephemeral ports (49152–65535):** Used for private or temporary purposes.

### User Datagram Protocol (UDP)

UDP is less reliable but **faster** than TCP.

- **Reliability:** No three-way handshake and no guarantee of data delivery or segment order.
- **Use Cases:** Preferred when **latency is critical** and packet loss is acceptable (voice/video calls, live streaming, gaming, DNS).
- **UDP Header:** Lighter than TCP header, including source/destination ports, length, and checksum.
- **Security Risk:** The lack of a handshake can be exploited by bad actors for denial of service (DoS) attacks.

## Application Layer Protocols

### Hypertext Transfer Protocol (HTTP)

HTTP follows the client-server model for communication (client request, server response) on port 80 (443 for HTTPS).

- **HTTP Request:** Includes the HTTP method, version, host, and metadata (**HTTP header**) like user agent and accepted content format.
- **HTTP Response:** Includes the response object and an **HTTP status code** (100–500 series) indicating the request outcome.
- **Common Methods:**
  - **GET:** Retrieve data (idempotent).
  - **POST:** Create new resources or send data (non-idempotent).
  - **PUT:** Update resources (idempotent).
  - **DELETE:** Remove resources (idempotent).
- **Versions:**
  - **HTTP/1.1:** Most widely used; supports reuse of TCP connections.
  - **HTTP/2:** Optimized header compression; uses a single TCP connection; supports **server push** (avoiding client polling).
  - **HTTP/3 (QUIC):** Improves speed over HTTP/2 by using **UDP** instead of TCP/IP, employing a congestion control algorithm.

### Simple Mail Transfer Protocol (SMTP)

SMTP is an application layer protocol for **email communication**.

- **Mechanism:** Uses a **stateful transmission channel** established between the SMTP client and server (or a **relay server** for cross-domain communication).
- **MTAs:** SMTP clients and servers are referred to as Mail Transfer Agents.
- **Attachments:** Handled by **Multipurpose Internet Mail Extensions (MIMEs)**, which extends SMTP to support media and non-ASCII character conversion.
- **Ports:** Port 25 (plain-text) and Port 587 (encrypted).
- **Nature:** Operates on a **push mechanism**.
- **Mail Retrieval Protocols (Pull Mechanism):**
  - **POP (Post Office Protocol):** Downloads email locally and deletes it from the server.
  - **IMAP (Internet Message Access Protocol):** Reads directly from the server without deleting, allowing access on multiple devices.

### Extensible Messaging and Presence Protocol (XMPP)

XMPP is an instant message protocol for **near real-time communication**, based on XML.

- **Features:** Includes **presence information** (user status) and a **roster** (contact list).
- **Messaging:** Streams **XML stanzas** (fundamental unit of communication) over a persistent TCP or HTTP connection. WebSockets can be used as a subprotocol.
- **JID:** Every user has a unique **Jabber ID** (JID, e.g., `myUserId@example.com`). Multiple devices are identified using a resource identifier (e.g., `myUserId@example.com/mobile`).

### Message Queuing Telemetry Transport (MQTT)

MQTT is designed for low-resource telemetry data, commonly used for **IoT device communication**.

- **Model:** Based on the **pub/sub model** using MQTT brokers.
- **Quality of Service (QoS):** Defines message delivery guarantees.
  - **QoS Level 0 (At most once):** "Fire and forget." Least reliable, most efficient.
  - **QoS Level 1 (At least once):** Guarantees delivery at least once (duplicates possible).
  - **QoS Level 2 (Exactly once):** Guarantees delivery exactly once (most reliable, least efficient).

## Communication Types

- **Synchronous (Sync):** The sender **blocks (waits)** for the execution to return before continuing. Preferred when a real-time response is needed.
- **Asynchronous (Async):** The sender **does not block** and execution continues. Preferred when flexibility and robustness are more important.

| Mechanism      | Description                                                                                              |
| :------------- | :------------------------------------------------------------------------------------------------------- |
| **Pull-based** | The client repeatedly sends requests to the server after some time, asking for a response (**polling**). |
| **Push-based** | The server delivers the response to the client without being asked.                                      |

### Pull Mechanism: HTTP Polling

- **HTTP Regular Polling:** Clients ask the server for status at short, regular intervals (e.g., five seconds). Wastes network bandwidth and resources.
- **HTTP Long Polling:** Clients ask the server, and the server **holds the connection** until there is a change in status or a fixed interval expires. Clients reestablish the connection after expiration.

### Push Mechanism: WebSockets

WebSockets provide a **bidirectional persistent connection** (full-duplex) over a single TCP connection.

- **Handshake:** Initiated by an HTTP `GET` call with `Connection: Upgrade` and `Upgrade: websocket`. The server replies with **101 Switching Protocols**.
- **Data Transfer:** Messages are sent as frames (textual or binary). Frames must be **masked** (XORed with a 4-byte key) before sending to the server to ensure security.

### Push Mechanism: Server-Sent Events (SSEs)

SSEs are used for **server-to-client (unidirectional) communication** over a long-lived HTTP connection. The client defines an `EventSource` to consume updates. SSEs can automatically reestablish dropped connections and recover missed messages.

## Common Communication Protocol Standards

### Remote Procedure Call (RPC)

RPC is executing a piece of code (a procedure) on a remote machine as if it were being executed locally.

- **Benefits:** Enables code reusability, scalability, and abstracts network communication. Supports cross-language/platform interaction via **marshaling** (encoding) and **unmarshaling** (decoding).
- **Stub:** An intermediary function that exposes the remote method interface and handles the internal details of network communication.
- **Interface Definition Language (IDL):** A language-agnostic contract defining remote procedures and data types (e.g., WSDL for SOAP).
- **SOAP:** A protocol often used with RPC, based on XML messages, offering built-in advanced security but known for complexity.

### Representational State Transfer (REST)

REST is a **software architectural style** widely used with HTTP.

- **Resources:** Fundamental entities uniquely identified by a URL.
- **Stateless:** Server does not maintain state across requests; all necessary information must be part of the HTTP request.
- **Cacheable:** Responses can be cached.
- **Uniform Interface:** Follows standardized ways for communication.

### GraphQL

GraphQL is an **API query language** that allows clients to specify exactly what data they need from a **single API endpoint**.

- **Efficiency:** Resolves **overfetching or underfetching** issues common in REST, consuming only necessary bandwidth.
- **Schema:** Uses a **strong type system** defined in **GraphQL Schema Definition Language (SDL)**.
- **Mutations:** Used for data modification operations (create, update, delete).
- **Subscriptions:** Used to establish **bidirectional connections** for near real-time events.

### Web Real-Time Communication (WebRTC)

WebRTC is a tool that supports **audio and video communication** directly between browsers/apps, and file sharing.

- **Connection:** Allows direct **peer-to-peer connection**, minimizing server involvement.
- **ICE (Interactive Connectivity Establishment):** Helps figure out the optimal communication route.
- **STUN (Session Traversal Utilities for NAT):** Used when devices are behind NAT to discover public IP/port information, which is then exchanged via **SDP (Session Description Protocol)**.
- **TURN (Traversal Using Relays around NAT):** Used as a relay server if STUN fails due to firewalls, though it is more expensive.
