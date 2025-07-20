# Home Assistant Helm Chart

Kubernetes Helm chart for Home Assistant with PostgreSQL, WebDAV, and automatic configuration management.

## Features

- **PostgreSQL Integration** - Built-in or external database support
- **Automatic Config Generation** - Optional templated configuration.yaml
- **WebDAV Access** - Nginx sidecar with Home Assistant token authentication
- **HACS Support** - Automatic HACS installation
- **Persistent Storage** - Separate PVC for configs

## Configuration

### Basic Options

```yaml
# Disable automatic config generation
configGeneration:
  enabled: false

# Enable WebDAV
dav:
  enabled: true
  port: 8080

# Use external PostgreSQL
postgresql:
  enabled: false
externalPostgres:
  host: postgres.example.com
  username: homeassistant
  passwordFromSecretKeyRef:
    name: postgres-secret
    key: password
```

### WebDAV Authentication

Access WebDAV at `http://<service>:8080/` using a Home Assistant long-lived access token:

```bash
curl -H "Authorization: Bearer <your-ha-token>" http://service:8080/
```

## Development

### Prerequisites

```bash
nix-shell  # Includes helm, kubectl, helm-unittest
```

### Testing

```bash
# Run unit tests
helm unittest .

# Lint chart
helm lint .

# Test template rendering
helm template test .
```
