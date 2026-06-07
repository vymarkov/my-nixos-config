# Connect to MinIO S3 with AWS CLI

MinIO on the `nixos` host exposes an S3-compatible API on port **9000**. The web console runs on port **9001**.

Access is available from the LAN (`enp2s0`, `wlp3s0`) and over **Tailscale** (`tailscale0` is trusted by the firewall).

## Prerequisites

Install the AWS CLI (not included in the NixOS config by default):

```bash
nix-shell -p awscli2
# or: nix profile install nixpkgs#awscli2
```

## Get credentials

Root credentials are stored in [`secrets/minio.yaml`](../secrets/minio.yaml) and managed with sops:

```bash
cd secrets
SOPS_AGE_KEY_FILE=age-keys.txt sops -d minio.yaml
```

The decrypted file contains:

```
MINIO_ROOT_USER=...
MINIO_ROOT_PASSWORD=...
```

Use these values as the AWS access key ID and secret access key respectively.

## Configure a profile

Replace `nixos` with the host's LAN IP or Tailscale hostname if needed (e.g. `nixos.tail1234.ts.net`).

```bash
export AWS_ACCESS_KEY_ID="<MINIO_ROOT_USER>"
export AWS_SECRET_ACCESS_KEY="<MINIO_ROOT_PASSWORD>"

aws configure set profile.minio.region us-east-1
aws configure set profile.minio.aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set profile.minio.aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set profile.minio.endpoint_url http://nixos:9000
aws configure set profile.minio.s3.addressing_style path
```

MinIO requires **path-style** addressing (`s3.addressing_style = path`). Without it, some AWS CLI commands fail with signature or DNS errors.

## Verify connectivity

```bash
aws --profile minio s3 ls
```

If no buckets exist yet, the command returns an empty list (no error).

## Create and use a bucket

Create a bucket via the [MinIO console](http://nixos:9001) or AWS CLI:

```bash
aws --profile minio s3 mb s3://my-bucket
```

Upload a file:

```bash
echo "hello" > /tmp/test.txt
aws --profile minio s3 cp /tmp/test.txt s3://my-bucket/test.txt
```

List objects:

```bash
aws --profile minio s3 ls s3://my-bucket/
```

Download a file:

```bash
aws --profile minio s3 cp s3://my-bucket/test.txt /tmp/downloaded.txt
```

Sync a local directory:

```bash
aws --profile minio s3 sync ./photos s3://my-bucket/photos
```

## One-off commands without a profile

```bash
aws s3 ls \
  --endpoint-url http://nixos:9000 \
  --region us-east-1 \
  --profile minio
```

Or with environment variables only:

```bash
export AWS_ACCESS_KEY_ID="<MINIO_ROOT_USER>"
export AWS_SECRET_ACCESS_KEY="<MINIO_ROOT_PASSWORD>"
export AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://nixos:9000 s3 ls
```

## Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `Could not connect to the endpoint URL` | Wrong hostname/IP, MinIO not running, or firewall blocking the client network |
| `SignatureDoesNotMatch` | Wrong secret key, or clock skew on the client |
| `PermanentRedirect` / DNS errors | Missing path-style addressing — set `s3.addressing_style = path` |
| `Access Denied` | Bucket policy or IAM-style restrictions in MinIO console |

Check that MinIO is running:

```bash
systemctl status minio
curl -I http://127.0.0.1:9000/minio/health/live
```

## Related modules

| File | Purpose |
|------|---------|
| [`modules/services/minio.nix`](../modules/services/minio.nix) | MinIO service, firewall, sops credentials |
| [`modules/roles/storage.nix`](../modules/roles/storage.nix) | Enables storage role; includes `minio-client` (`mc`) |
| [`secrets/minio.yaml`](../secrets/minio.yaml) | Encrypted root credentials |

For interactive bucket management, `mc` (MinIO Client) is also available on the host — see `mc alias set` in the MinIO documentation.
