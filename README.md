# Convex Helm Chart

A Helm chart for deploying [Convex Backend](https://github.com/get-convex/convex-backend) on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (for local storage mode)

## Installation

```bash
helm repo add convex https://ajac-zero.github.io/convex-helm
helm repo update
```

### Quick Start (Development)

```bash
# Generate an instance secret (must be hex-encoded)
INSTANCE_SECRET=$(openssl rand -hex 32)

# Install with SQLite (development only)
helm install convex convex/convex \
  --set instance.secret="$INSTANCE_SECRET" \
  --set urls.cloudOrigin="http://localhost:3210"
```

### Production with PostgreSQL

```bash
helm install convex convex/convex \
  --set instance.secret="$INSTANCE_SECRET" \
  --set database.type=postgres \
  --set database.postgres.url="postgres://user:password@host:5432" \
  --set urls.cloudOrigin="https://api.your-domain.com" \
  --set urls.siteOrigin="https://api.your-domain.com/http" \
  --set ingress.enabled=true \
  --set ingress.backend.host="api.your-domain.com" \
  --set ingress.backend.tls.enabled=true
```

### Production with PostgreSQL and S3

```bash
helm install convex convex/convex \
  --set instance.secret="$INSTANCE_SECRET" \
  --set database.type=postgres \
  --set database.postgres.url="postgres://user:password@host:5432" \
  --set storage.type=s3 \
  --set storage.s3.accessKeyId="YOUR_ACCESS_KEY" \
  --set storage.s3.secretAccessKey="YOUR_SECRET_KEY" \
  --set storage.s3.region="us-east-1" \
  --set storage.s3.buckets.exports="convex-exports" \
  --set storage.s3.buckets.snapshotImports="convex-imports" \
  --set storage.s3.buckets.modules="convex-modules" \
  --set storage.s3.buckets.files="convex-files" \
  --set storage.s3.buckets.search="convex-search"
```

## Configuration

### Instance Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `instance.name` | Unique instance identifier | `convex-self-hosted` |
| `instance.secret` | Instance secret (required) | `""` |
| `instance.existingSecret` | Use existing secret | `""` |

### Backend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.image.repository` | Backend image repository | `ghcr.io/get-convex/convex-backend` |
| `backend.image.tag` | Backend image tag | `latest` |
| `backend.replicas` | Number of replicas | `1` |
| `backend.resources.requests.memory` | Memory request | `512Mi` |
| `backend.resources.requests.cpu` | CPU request | `250m` |
| `backend.resources.limits.memory` | Memory limit | `2Gi` |
| `backend.resources.limits.cpu` | CPU limit | `2000m` |

### Dashboard Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `dashboard.enabled` | Enable dashboard | `true` |
| `dashboard.image.repository` | Dashboard image | `ghcr.io/get-convex/convex-dashboard` |
| `dashboard.image.tag` | Dashboard image tag | `latest` |
| `dashboard.replicas` | Number of replicas | `1` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.type` | Database type: `sqlite`, `postgres`, `mysql` | `sqlite` |
| `database.postgres.url` | PostgreSQL connection URL | `""` |
| `database.postgres.existingSecret` | Use existing secret for URL | `""` |
| `database.mysql.url` | MySQL connection URL | `""` |
| `database.mysql.existingSecret` | Use existing secret for URL | `""` |
| `database.sqlite.path` | SQLite database path | `/convex/data/db.sqlite3` |
| `database.disableSSL` | Disable SSL (dev only) | `false` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `storage.type` | Storage type: `local` or `s3` | `local` |
| `storage.s3.accessKeyId` | AWS access key ID | `""` |
| `storage.s3.secretAccessKey` | AWS secret access key | `""` |
| `storage.s3.region` | AWS region | `us-east-1` |
| `storage.s3.endpoint` | Custom S3 endpoint (for R2, MinIO) | `""` |
| `storage.s3.buckets.exports` | Exports bucket name | `""` |
| `storage.s3.buckets.snapshotImports` | Imports bucket name | `""` |
| `storage.s3.buckets.modules` | Modules bucket name | `""` |
| `storage.s3.buckets.files` | Files bucket name | `""` |
| `storage.s3.buckets.search` | Search bucket name | `""` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Storage size | `10Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.backend.host` | Backend hostname | `""` |
| `ingress.backend.tls.enabled` | Enable TLS | `false` |
| `ingress.backend.tls.secretName` | TLS secret name | `""` |
| `ingress.dashboard.host` | Dashboard hostname | `""` |
| `ingress.dashboard.tls.enabled` | Enable TLS | `false` |

### URL Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `urls.cloudOrigin` | Backend API URL (external) | `""` |
| `urls.siteOrigin` | HTTP actions URL (external) | `""` |

## Using Existing Secrets

For production, you should use existing Kubernetes secrets:

```yaml
instance:
  existingSecret: "my-convex-secret"
  existingSecretKey: "instance-secret"

database:
  type: postgres
  postgres:
    existingSecret: "my-postgres-secret"
    existingSecretKey: "connection-url"

storage:
  type: s3
  s3:
    existingSecret: "my-aws-secret"
    accessKeyIdKey: "access-key-id"
    secretAccessKeyKey: "secret-access-key"
```

## Upgrading

```bash
helm upgrade convex . -f values.yaml
```

## Uninstalling

```bash
helm uninstall convex
```

**Note:** PersistentVolumeClaims are not deleted automatically. To delete data:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=convex
```

## Generating Admin Key

After installation, generate an admin key:

```bash
kubectl exec -it deploy/convex-backend -- ./generate_admin_key.sh
```

Use this key in your application's `CONVEX_SELF_HOSTED_ADMIN_KEY` environment variable.

## Health Checks

The backend exposes a `/version` endpoint used for liveness and readiness probes.

## Troubleshooting

### Check pod logs

```bash
kubectl logs -l app.kubernetes.io/component=backend
kubectl logs -l app.kubernetes.io/component=dashboard
```

### Check pod status

```bash
kubectl get pods -l app.kubernetes.io/instance=convex
```

### Database connection issues

Ensure your database is in the same region as your Kubernetes cluster for optimal latency.

## License

This chart is provided as-is. Convex Backend is licensed under the [Convex License](https://github.com/get-convex/convex-backend/blob/main/LICENSE).
