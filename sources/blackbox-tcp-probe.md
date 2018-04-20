# TCP探针

```
# The preferred IP protocol of the TCP probe (ip4, ip6).
[ preferred_ip_protocol: <string> | default = "ip6" ]

# The source IP address.
[ source_ip_address: <string> ]

# The query sent in the TCP probe and the expected associated response.
# starttls upgrades TCP connection to TLS.
query_response:
  [ - [ [ expect: <string> ],
        [ send: <string> ],
        [ starttls: <boolean | default = false> ]
      ], ...
  ]

# Whether or not TLS is used when the connection is initiated.
[ tls: <boolean | default = false> ]

# Configuration for TLS protocol of TCP probe.
tls_config:
  [ <tls_config> ]
```