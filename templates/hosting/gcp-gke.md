# API Hosting: GCP GKE (Kubernetes)

## Dockerfile
Standard multi-stage .NET Dockerfile — same pattern as [azure-container-apps.md](azure-container-apps.md). Replace `[Project].API` with your project name.

---

## Port binding
No forced env var. Configure the container port in your Kubernetes manifest:
```yaml
# .k8s/deployment.yaml
containers:
  - name: myapp-api
    image: REGION-docker.pkg.dev/PROJECT/myapp/api:TAG
    ports:
      - containerPort: 8080
```
ASP.NET Core 8+ defaults to `8080` in containers — no code change needed.

---

## Health check
```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>();  // optional — checks DB connectivity

app.MapHealthChecks("/health");
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

Kubernetes probes in `.k8s/deployment.yaml`:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20
  failureThreshold: 3
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
```

---

## Secrets / configuration
Use **External Secrets Operator** to sync GCP Secret Manager → Kubernetes Secrets automatically. Avoids committing secrets or using kubectl to set them manually:
```yaml
# externalsecret.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-api-secrets
spec:
  secretStoreRef:
    name: gcp-secret-store
    kind: ClusterSecretStore
  target:
    name: myapp-api-secrets
  data:
    - secretKey: db-connection
      remoteRef:
        key: myapp-db-connection
```

Reference in deployment:
```yaml
envFrom:
  - secretRef:
      name: myapp-api-secrets
```

---

## Kubernetes manifests
Add `.k8s/` to the repo root:
```
.k8s/
├── deployment.yaml     ← pod spec, resources, probes, env
├── service.yaml        ← ClusterIP (internal) or LoadBalancer (external)
├── ingress.yaml        ← TLS, host routing (use GKE Ingress or Gateway API)
└── externalsecret.yaml ← syncs GCP Secret Manager → K8s Secrets
```

`service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-api
spec:
  selector:
    app: myapp-api
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

`ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-api
  annotations:
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: myapp-api-ip
spec:
  tls:
    - secretName: myapp-tls
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-api
                port:
                  number: 80
```

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to GKE

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to GCP (Workload Identity)
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github/providers/github
          service_account: github-actions@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com

      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2

      - name: Build and push to Artifact Registry
        run: |
          gcloud builds submit \
            --tag ${{ secrets.GCP_REGION }}-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/myapp/api:${{ github.sha }}

      - name: Get GKE credentials
        uses: google-github-actions/get-gke-credentials@v2
        with:
          cluster_name: ${{ secrets.GKE_CLUSTER_NAME }}
          location: ${{ secrets.GCP_REGION }}

      - name: Update image and roll out
        run: |
          kubectl set image deployment/myapp-api \
            myapp-api=${{ secrets.GCP_REGION }}-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/myapp/api:${{ github.sha }}
          kubectl rollout status deployment/myapp-api --timeout=5m
```
