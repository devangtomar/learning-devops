# Caching Policies & Strategies — Notes (Markdown)

> Concise, structured study notes with missing topics added: metrics, algorithms, implementation details, distributed concerns, HTTP/CDN headers, pitfalls, and quick reference pseudo-code.

---

## 1. What is a cache

* **Definition:** a fast storage layer that keeps frequently-used data closer to the consumer (CPU, app server, edge) to reduce latency and backend load.
* **Principle:** *locality of reference* — temporal and spatial locality.
* **Outcomes:**

  * **Hit:** requested item is found → low latency.
  * **Miss:** not found → fetch from slower store → higher latency.

---

## 2. Key metrics & terms

* **Hit rate** = hits / requests (higher = good)
* **Miss rate** = misses / requests
* **Hit time** = time to retrieve from cache
* **Miss penalty** = extra time to fetch from origin + update cache
* **AMAT (Average memory access time)** = `HitTime + MissRate * MissPenalty`
* **Throughput** (ops/sec), **P95/P99 latency**, **cache size**, **eviction count**, **byte hit ratio** (useful for large objects)
* **Cold start (cold cache):** cache empty → initial misses
* **Warm-up:** pre-populating cache for steady state

---

## 3. Eviction / admission fundamentals

* **Admission vs Eviction**

  * **Admission**: should a fetched item be placed into cache? (e.g., TinyLFU admits hot items)
  * **Eviction**: which item to remove when full?
* **Design goals:** maximize hit rate, minimize latency, control memory fragmentation, avoid pathological patterns.

---

## 4. Classic eviction algorithms (high level + added variants)

* **Belady’s (OPT)** — *optimal* (requires future knowledge). Used as benchmark.
* **Queue-based**

  * **FIFO** — evict oldest inserted. Simple, can age useful items.
  * **LIFO** — evict most recently inserted. Rarely used for caching.
* **Recency-based**

  * **LRU (Least Recently Used)** — evict least recently accessed. Common; O(1) implementations use hashmap + doubly linked list.
  * **MRU** — evict most recently used. Useful for certain access patterns.
  * **Clock** (approx LRU) — efficient, uses reference bit.
* **Frequency-based**

  * **LFU (Least Frequently Used)** — evict least accessed; requires counters.
  * **LFRU** — hybrid of LFU+LRU.
* **Adaptive / modern**

  * **ARC** (Adaptive Replacement Cache) — balances recency & frequency.
  * **CAR** — clock-based adaptive replacement.
  * **LIRS** — low inter-reference recency set (good for certain workloads).
  * **TinyLFU / W-TinyLFU** — LFU admission with an LRU window; used in high-performance caches (e.g., Caffeine).
* **Implementation notes**

  * LRU: `O(1)` with hashmap + DLL.
  * LFU naive: counters + heap → higher cost; use frequency lists for `O(1)`.

---

## 5. Cache strategies (data synchronization)

* **Cache-aside (lazy loading)**

  * App checks cache → miss → read origin → write cache → return.
  * Good when you want control and selective caching.
* **Read-through**

  * Cache itself fetches from origin on miss and populates cache automatically.
  * Good for transparent caching layers.
* **Refresh-ahead**

  * Proactively refresh items before TTL expires (background).
  * Reduces misses for hot items.
* **Write-through**

  * Writes go to cache **and** origin synchronously.
  * Simplifies consistency (origin always up-to-date); higher write latency.
* **Write-around**

  * Writes bypass cache to origin (do not populate cache).
  * Avoids filling cache with write-heavy items; can cause cold reads after writes.
* **Write-back (write-behind)**

  * Writes to cache; origin updated asynchronously later.
  * Fast writes; risk of data loss on crash unless durable persistence used.
* **Stale-while-revalidate / Stale-if-error (HTTP)**

  * Serve stale content while revalidating in background; improves availability.
* **Negative caching**

  * Cache "not found" results for brief period to avoid repeating expensive misses.

**Pseudo-code (cache-aside):**

```pseudo
value = cache.get(key)
if value == null:
    value = db.read(key)
    cache.put(key, value, ttl)
return value
```

---

## 6. HTTP / CDN caching essentials (added details)

* **Important headers**

  * `Cache-Control: max-age=<s>, public|private, no-cache, no-store, must-revalidate, s-maxage=<s>`
  * `ETag` / `If-None-Match` (validation)
  * `Last-Modified` / `If-Modified-Since`
  * `Vary` — marks request headers that affect cached response (e.g., `Vary: Accept-Encoding` or `Vary: Cookie`)
* **Directives & behavior**

  * `public` — can be cached by CDNs/shared caches
  * `private` — only client caches
  * `no-cache` — must revalidate before serving
  * `no-store` — do not store response in cache
* **CDN modes**

  * **Push CDN:** pre-populate edge caches (good for static content, predictable content)
  * **Pull CDN:** edges fetch on first request (good for large catalogs)
* **CDN optimization**

  * `stale-while-revalidate`, `stale-if-error`
  * **ESI** (Edge Side Includes) for fragment caching
  * **Client multiplexing, HTTP/2 or HTTP/3**, TLS session reuse
  * **DNS routing** and geo DNS to nearest POP
  * **Multi-tier CDN** (regional + local edges)
* **Content consistency**

  * TTL, purge/invalidation APIs, lease/refresh protocols, origin versioning

---

## 7. Distributed caching & scale (added deeper content)

* **Partitioning (sharding)**

  * **Client-side consistent hashing** — maps keys to nodes (reduces remapping on node changes)
  * **Rendezvous hashing** — alternative with good balance
* **Replication**

  * For read availability; choose primary/replica model or quorum reads
* **Cache coherence / consistency**

  * **Eventual consistency** common in distributed caches
  * Invalidation strategies: explicit invalidation events, pub/sub invalidation, versioned keys
* **Hot keys / hotspots**

  * Mitigate via replication, request routing, throttling, rate-limiting, or key-splitting
* **Cache-as-a-service / cluster management**

  * Auto-scaling, failover, partition rebalancing
* **Network considerations**

  * Serialization cost, network RTT, pipelining, batching

---

## 8. Implementation & product notes (Memcached vs Redis + extras)

### Memcached

* **Simple key-value in-memory cache**, multithreaded.
* **Slab allocator** to reduce fragmentation (fixed-size classes).
* **Typical use:** session caches, object caches; usually cache-aside, LRU.
* **Limitations:** no persistence, limited data types, no complex ops or built-in clustering (client-side sharding common).

### Redis

* **In-memory data structures** (strings, lists, sets, hashes, bitmaps, geospatial, sorted sets, HyperLogLog).
* **Persistence options:** RDB snapshots, AOF (append-only file) — trade durability vs latency.
* **Eviction policies** (examples): `noeviction`, `allkeys-lru`, `volatile-lru`, `allkeys-lfu`, `volatile-ttl`, etc.
* **Advanced features:** pub/sub, Lua scripting, transactions, replication, Redis Cluster for sharding.
* **Use cases:** session store, leaderboards, counters, message bus, complex caching patterns.
* **Safety:** configure `maxmemory` and eviction policy; beware of AOF rewrite cost and replication lag.

---

## 9. Practical engineering topics (missing from original)

### Data structures & cost

* LRU: hashmap + doubly-linked list → `O(1)` get/put/evict.
* LFU: frequency lists or min-heap; can be `O(1)` with careful design (freq lists).
* Clock algorithm: low overhead for LRU approximation.

### Admission policies & bloom filters

* **Admission**: use sampling or TinyLFU to avoid caching one-off large items.
* **Bloom filters**: avoid expensive origin fetches for known-nonexistent keys (negative cache).

### Thundering herd / cache stampede

* **Problem:** many requests for same uncached key.
* **Mitigations:**

  * Request coalescing / singleflight (only one backend fetch, others wait).
  * Locking per-key (with timeout).
  * Probabilistic early refresh (refresh-ahead).
  * Stale-while-revalidate to serve stale while refreshes happen.

### Cache poisoning & security

* Validate keys/inputs; avoid caching sensitive per-user payloads without `Vary` or `private`.
* Use authentication/ACL at cache-layer if caching private data.
* Sanitize web headers to avoid cache control bypass.

### Performance & monitoring

* Monitor: hit ratio, miss rate, eviction rate, memory usage, p95/p99 latencies, CPU usage, network RTTs.
* Alarms on increased miss rate or high evictions (indicates sizing or policy issues).
* Benchmarks: realistic workload (R/W ratio, key distribution, object sizes).

### When **not** to cache

* Highly dynamic / real-time data where strict consistency is required.
* Low read / high write workloads (unless write-through with careful invalidation).
* Sensitive private data unless properly scoped (`private` caches).

---

## 10. Design checklist (quick)

* Is the data **cacheable**? idempotent reads, not sensitive, reasonable size.
* Access pattern: read-heavy? temporal locality? zipf / Pareto?
* Required **consistency**: strong vs eventual.
* Latency goals & SLOs → choose in-memory vs local cache vs CDN.
* Eviction policy → LRU/TinyLFU/ARC?
* Admission policy → TinyLFU or sample-based?
* Invalidation → TTL, explicit purge, versioning?
* Failure modes → stampede, cold start, node loss.
* Monitoring & instrumentation in place?

---

## 11. Common patterns & anti-patterns

**Patterns**

* Cache-aside for selective caching and control.
* Read-through for transparent caching layers.
* Stale-while-revalidate at CDNs for high availability.
* Two-level caches: local (in-process) + remote (Redis) for lowest latency and shared state.
  **Anti-patterns**
* Caching everything blindly (large items + low reuse).
* Long TTLs with no invalidation for frequently updated content.
* Relying on LRU only with adversarial/sweep workloads (use admission control).

---

## 12. Short algorithm cheat-sheet

* **Best for simple recency:** LRU (hash + DLL).
* **Best for frequency-heavy hot items:** LFU (or TinyLFU).
* **Best for mixed recency+frequency:** ARC or W-TinyLFU.
* **Approx LRU with low overhead:** Clock.

---

## 13. Useful pseudo-code snippets

**Write-through**

```pseudo
cache.put(key, value)
db.write(key, value)
return ok
```

**Write-back**

```pseudo
cache.put(key, value, dirty=true)
# background thread flushes dirty entries to db periodically
```

**Read-through (cache layer handles miss)**

```pseudo
value = cache.get(key)
if value == null:
    value = cache.loadFromOrigin(key)   # cache does the fetch
    cache.put(key, value)
return value
```

**Singleflight (thundering herd mitigation)**

```pseudo
if in_flight_fetch_exists(key):
    wait for fetch result
else:
    mark_in_flight(key)
    value = fetch_from_origin(key)
    cache.put(key, value)
    unmark_in_flight(key)
    notify_waiters(key, value)
```

---

## 14. Monitoring / SLO examples (recommendations)

* **SLOs:** p95 cache latency < X ms; hit rate ≥ Y% (depends on app).
* **Metrics to collect:** hits, misses, evictions, expirations, memory usage, object size distribution, request rate.
* **Alert examples:** sudden drop in hit rate, eviction rate spike, memory > 80%.

---

## 15. Summary / TL;DR

* Caching reduces latency by exploiting locality; success depends on *what* you cache, *how* you evict, and *how* you keep consistency.
* Choose eviction/admission policy based on workload: LRU for recency, LFU/TinyLFU for frequency, ARC for mixed.
* For distributed systems, design for partitioning, replication, invalidation, and stampede protection.
* Monitor hit/miss rates, evictions, and latencies; tune TTLs, sizes, and policies iteratively.

---

## 16. Appendix — quick comparison table

| Concern       |          Cache-aside |                 Read-through | Write-through |          Write-back |
| ------------- | -------------------: | ---------------------------: | ------------: | ------------------: |
| Read latency  |                  low |                          low |           n/a |                 n/a |
| Write latency | origin-write on miss | origin handled automatically |   high (sync) |         low (async) |
| Consistency   |       app-controlled |             cache-controlled | strong (sync) |      weaker (async) |
| Complexity    |               medium |                       medium |           low | higher (durability) |

