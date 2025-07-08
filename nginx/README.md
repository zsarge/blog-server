This server is build expecting a system level NGINX instance.

This instance should:
- Be configured with certbot to automatically renew ssl certs
- Automatically rate limit the `/files` endpoint

## Serving files with nginx

```
# configure group
sudo usermod -a -G blog-server www-data

# let nginx access files
sudo chown -R :www-data /home/blog-server/blog-server-cache
```

This should fix 403 forbidden.

