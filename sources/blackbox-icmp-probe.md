# ICMP探针

```
# The preferred IP protocol of the ICMP probe (ip4, ip6).
[ preferred_ip_protocol: <string> | default = "ip6" ]

# The source IP address.
[ source_ip_address: <string> ]

# Set the DF-bit in the IP-header. Only works with ip4 and on *nix systems.
[ dont_fragment: <boolean> | default = false ]

# The size of the payload.
[ payload_size: <int> ]
```