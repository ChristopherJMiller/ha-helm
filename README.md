# Home Assistant Helm Chart

Kubernetes Helm chart for Home Assistant with PostgreSQL, WebDAV, and automatic configuration management.

## Features

- **PostgreSQL Integration** - Built-in or external database support
- **Automatic Config Generation** - Optional templated configuration.yaml
- **GitOps config delivery** - Mount git-tracked HA config (packages, dashboards) from ConfigMaps/Secrets
- **Fail-fast validation** - Optional `check_config` init container blocks startup on bad config
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

### GitOps Config Delivery

This chart owns the *mechanism* to render and mount HA config; the consuming
repo (e.g. an Argo CD app) owns the *content*. Config comes in two forms:

**Generated `configuration.yaml`** (when `configGeneration.enabled`) — top-level
keys from `haconfig` are spliced in, plus a single merged `homeassistant:` block:

```yaml
externalUrl: https://ha.example.com   # -> homeassistant.external_url
packages:
  enabled: true                       # -> homeassistant.packages: !include_dir_named packages/
haconfig:
  homeassistant:                      # merged into the SAME homeassistant block
    time_zone: America/New_York
```

`externalUrl`, `packages`, and any `haconfig.homeassistant` map are merged so
exactly one `homeassistant:` block is emitted (no duplicate keys).

**`extraConfigMounts`** — mount arbitrary ConfigMaps/Secrets as directories
under `/config`. The consumer creates these out of band (e.g. kustomize
`configMapGenerator`); the chart only references them by name. These are
directory mounts (no `subPath`) so ConfigMap/Secret updates propagate live:

```yaml
packages:
  enabled: true          # expects package files at /config/packages
lovelace:
  enabled: true
  dashboards:
    - urlPath: lovelace-home
      filename: dashboards/home.yaml   # relative to /config
      title: Home
      showInSidebar: true

extraConfigMounts:
  - name: packages
    configMap: ha-packages       # created by the consumer
    mountPath: /config/packages
  - name: dashboards
    configMap: ha-dashboards
    mountPath: /config/dashboards
  # secret: instead of configMap: is also supported
```

`packages.enabled` pairs with an `extraConfigMounts` entry at `/config/packages`;
`lovelace` YAML dashboards reference files delivered under a mounted directory
(e.g. `/config/dashboards`). The global lovelace `mode` stays `storage` so the
default UI dashboard and HACS custom-card resource auto-registration keep working.

### Fail-fast Config Validation

Enable an init container that runs `homeassistant --script check_config` after
config generation and after `extraConfigMounts` are mounted, so an invalid
automation/package blocks pod startup instead of taking a running HA down:

```yaml
checkConfig:
  enabled: true
```

### Reload on Change

The chart does **not** watch ConfigMaps for changes — that's the consumer's job.
`podAnnotations` passthrough is provided so you can annotate the pod for
[stakater/reloader](https://github.com/stakater/Reloader):

```yaml
podAnnotations:
  reloader.stakater.com/auto: "true"
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
