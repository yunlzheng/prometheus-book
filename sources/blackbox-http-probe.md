# HTTP探针

http_probe:

```
 # Accepted status codes for this probe. Defaults to 2xx.
  [ valid_status_codes: <int>, ... | default = 2xx ]

  # Accepted HTTP versions for this probe.
  [ valid_http_versions: <string>, ... ]

  # The HTTP method the probe will use.
  [ method: <string> | default = "GET" ]

  # The HTTP headers set for the probe.
  headers:
    [ <string>: <string> ... ]

  # Whether or not the probe will follow any redirects.
  [ no_follow_redirects: <boolean> | default = false ]

  # Probe fails if SSL is present.
  [ fail_if_ssl: <boolean> | default = false ]

  # Probe fails if SSL is not present.
  [ fail_if_not_ssl: <boolean> | default = false ]

  # Probe fails if response matches regex.
  fail_if_matches_regexp:
    [ - <regex>, ... ]

  # Probe fails if response does not match regex.
  fail_if_not_matches_regexp:
    [ - <regex>, ... ]

  # Configuration for TLS protocol of HTTP probe.
  tls_config:
    [ <tls_config> ]

  # The HTTP basic authentication credentials for the targets.
  basic_auth:
    [ username: <string> ]
    [ password: <secret> ]

  # The bearer token for the targets.
  [ bearer_token: <secret> ]

  # The bearer token file for the targets.
  [ bearer_token_file: <filename> ]

  # HTTP proxy server to use to connect to the targets.
  [ proxy_url: <string> ]

  # The preferred IP protocol of the HTTP probe (ip4, ip6).
  [ preferred_ip_protocol: <string> | default = "ip6" ]

  # The body of the HTTP request used in probe.
  body: [ <string> ]
```

tls_config:

```
# Disable target certificate validation.
[ insecure_skip_verify: <boolean> | default = false ]

# The CA cert to use for the targets.
[ ca_file: <filename> ]

# The client cert file for the targets.
[ cert_file: <filename> ]

# The client key file for the targets.
[ key_file: <filename> ]

# Used to verify the hostname for the targets.
[ server_name: <string> ]
```