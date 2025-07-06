This server is build expecting a system level NGINX instance.

This instance should:
- Be configured with certbot to automatically renew ssl certs
- Automatically rate limit the `/files` endpoint

## Rate Limiting with NGINX 

Modify `/etc/nginx/nginx.conf` (not just the server block) and add this to the top-level http block:

```
http {
    limit_req_zone $binary_remote_addr zone=file_limit:10m rate=60r/m;

    # ... your includes and other settings
    include /etc/nginx/conf.d/*.conf;
}

```

