# DNS探针

```
# The preferred IP protocol of the DNS probe (ip4, ip6).
[ preferred_ip_protocol: <string> | default = "ip6" ]

# The source IP address.
[ source_ip_address: <string> ]

[ transport_protocol: <string> | default = "udp" ] # udp, tcp

query_name: <string>

[ query_type: <string> | default = "ANY" ]

# List of valid response codes.
valid_rcodes:
  [ - <string> ... | default = "NOERROR" ]

validate_answer_rrs:

  fail_if_matches_regexp:
    [ - <regex>, ... ]

  fail_if_not_matches_regexp:
    [ - <regex>, ... ]

validate_authority_rrs:

  fail_if_matches_regexp:
    [ - <regex>, ... ]

  fail_if_not_matches_regexp:
    [ - <regex>, ... ]

validate_additional_rrs:

  fail_if_matches_regexp:
    [ - <regex>, ... ]

  fail_if_not_matches_regexp:
    [ - <regex>, ... ]
```