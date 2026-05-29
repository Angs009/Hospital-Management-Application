# Hospital Management System - AWS EKS Deployment Guide

Production-ready deployment guide for the Hospital Management System on AWS EKS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Application Overview](#application-overview)
- [Docker Build and Push](#docker-build-and-push)
- [Kubernetes Deployment](#kubernetes-deployment)
  - [Direct Manifests](#direct-manifests)
  - [Helm Chart](#helm-chart)
- [Validation and Testing](#validation-and-testing)
- [Troubleshooting](#troubleshooting)
- [Production Checklist](#production-checklist)

## Prerequisites

### Local Development

- Docker Desktop (with Kubernetes enabled) or Docker Engine
- kubectl (v1.27+)
- Helm (v3.10+)
- Git

### AWS EKS Cluster

- AWS Account with EKS cluster running (v1.27+)
- AWS CLI (v2+) configured with appropriate credentials
- kubectl configured to access the EKS cluster
- AWS EBS CSI Driver installed (for persistent volumes)
- Adequate IAM permissions for ECR, EKS, and EC2

### Docker Hub Account

- Docker Hub account with push permissions
- Local Docker authentication: `docker login`

## Application Overview

**Hospital Management System** is a Node.js Express application with the following components:

| Component | Details |
|-----------|---------|
| **Application Type** | Full-stack hospital management web application |
| **Backend Runtime** | Node.js 20, Express.js |
| **Frontend** | Static HTML, CSS, JavaScript served by Express |
| **Build Tool** | npm with `package-lock.json` |
| **Start Command** | `npm start` or `node backend/app.js` |
| **Port** | 5000 (HTTP) |
| **Database** | MongoDB 7 |
| **Main Dependencies** | `express`, `mongoose`, `express-session`, `connect-mongo`, `cors`, `bcryptjs`, `jsonwebtoken`, `nodemailer`, `dotenv` |
| **Health Endpoints** | `/healthz` (liveness), `/readyz` (readiness) |

### Key Features

- User authentication with sessions
- Patient registration and management
- Appointment scheduling
- Doctor management
- Admin portal with login
- MongoDB for persistent data and sessions
- Health and readiness probes for Kubernetes

## Docker Build and Push

### Build Local Docker Image

```bash
# Build the Docker image locally
docker build -t nanineelapu/hospital-app:1.0.0 .

# Verify the image
docker images | grep hospital-app
```

### Test Image Locally

```bash
# Run MongoDB container
docker run -d \
  --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -p 27017:27017 \
  mongo:7-jammy

# Run application container
docker run -d \
  --name hospital-app \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e MONGO_URI=mongodb://mongodb:27017/hospital_management \
  --link mongodb \
  nanineelapu/hospital-app:1.0.0

# Test application
curl http://localhost:5000/healthz
curl http://localhost:5000/readyz

# Cleanup
docker stop hospital-app mongodb
docker rm hospital-app mongodb
```

### Push to Docker Hub

```bash
# Login to Docker Hub (if not already logged in)
docker login

# Push image to Docker Hub
docker push nanineelapu/hospital-app:1.0.0

# Verify on Docker Hub
# Visit: https://hub.docker.com/r/nanineelapu/hospital-app

# Pull the image to verify it's accessible
docker pull nanineelapu/hospital-app:1.0.0
```

### Image Versioning Strategy

Each release should use immutable version tags:

```bash
# Production releases use version tags
docker tag nanineelapu/hospital-app:1.0.0 nanineelapu/hospital-app:v1.0.0
docker push nanineelapu/hospital-app:v1.0.0

# Update for v1.1.0
docker build -t nanineelapu/hospital-app:1.1.0 .
docker push nanineelapu/hospital-app:1.1.0

# Update in Helm values or deployment manifests
# sed -i 's/1.0.0/1.1.0/g' hospital-chart/values.yaml
# kubectl set image deployment/hospital-web hospital-web=nanineelapu/hospital-app:1.1.0
```

## Kubernetes Deployment

### Prerequisites for EKS

Before deploying, ensure:

1. **AWS EBS CSI Driver is installed:**

```bash
# Check if CSI driver is installed
kubectl get pods -n kube-system | grep ebs-csi

# Install if missing:
# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
```

2. **Create storage class (if not using Helm):**

```bash
kubectl apply -f k8s/pvc.yaml
# This creates the 'ebs-gp3' storage class and PVC
```

3. **Create namespace (optional but recommended):**

```bash
kubectl create namespace hospital
# Then add --namespace hospital to all kubectl commands
# Or use: kubectl config set-context --current --namespace=hospital
```

### Direct Kubernetes Manifests

Deploy using individual manifests:

```bash
# 1. Create namespace
kubectl create namespace hospital

# 2. Deploy all manifests
kubectl apply -f k8s/ -n hospital

# 3. Verify deployments
kubectl get pods -n hospital
kubectl get svc -n hospital

# 4. Wait for LoadBalancer IP (may take 2-5 minutes)
kubectl get svc hospital-web -n hospital --watch

# 5. Access the application
# Get the EXTERNAL-IP and open in browser
EXTERNAL_IP=$(kubectl get svc hospital-web -n hospital -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://${EXTERNAL_IP}"
```

### Helm Chart Deployment

**Recommended approach for production:**

#### Install Helm Chart

```bash
# 1. Create namespace
kubectl create namespace hospital

# 2. Generate required secrets (customize these values):
SESSION_SECRET=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
ADMIN_PASSWORD="ChangeMe123!@#"

# 3. Install chart with custom values
helm install hospital hospital-chart/ \
  --namespace hospital \
  --set secret.stringData.SESSION_SECRET=$SESSION_SECRET \
  --set secret.stringData.JWT_SECRET=$JWT_SECRET \
  --set secret.stringData.ADMIN_PASSWORD=$ADMIN_PASSWORD

# 4. Verify installation
helm status hospital -n hospital
kubectl get all -n hospital

# 5. Wait for LoadBalancer
kubectl get svc -n hospital --watch
```

#### Using Custom values-prod.yaml

For production deployments, create a custom values file:

```bash
# Create values-prod.yaml
cat > values-prod.yaml <<EOF
replicaCount: 3
image:
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

mongodb:
  persistence:
    size: 20Gi
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
EOF

# Install with custom values
helm install hospital hospital-chart/ \
  --namespace hospital \
  -f values-prod.yaml \
  --set secret.stringData.SESSION_SECRET=$SESSION_SECRET \
  --set secret.stringData.JWT_SECRET=$JWT_SECRET
```

#### Helm Chart Operations

```bash
# View release status
helm status hospital -n hospital

# List all releases
helm list -n hospital

# Get release values
helm get values hospital -n hospital

# Upgrade release
helm upgrade hospital hospital-chart/ \
  --namespace hospital \
  --set image.tag="1.1.0"

# Rollback release
helm rollback hospital 1 -n hospital

# Delete release
helm uninstall hospital -n hospital

# Dry-run before applying
helm install hospital hospital-chart/ \
  --namespace hospital \
  --dry-run --debug
```

## Validation and Testing

### Pod Health Checks

```bash
# Check pod status
kubectl get pods -n hospital
kubectl describe pod <pod-name> -n hospital

# View pod logs
kubectl logs -f deployment/hospital-web -n hospital
kubectl logs -f deployment/hospital-mongodb -n hospital

# Check readiness/liveness probes
kubectl get events -n hospital --sort-by='.lastTimestamp'
```

### Test Application Endpoints

```bash
# Get LoadBalancer endpoint
ENDPOINT=$(kubectl get svc hospital-web -n hospital -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Health probe
curl http://$ENDPOINT/healthz

# Readiness probe
curl http://$ENDPOINT/readyz

# API endpoints (examples)
curl http://$ENDPOINT/api/doctors
curl http://$ENDPOINT/api/patients
curl http://$ENDPOINT/api/appointments
```

### Database Connectivity

```bash
# Connect to MongoDB pod
kubectl exec -it deployment/hospital-mongodb -n hospital -- mongosh

# Inside MongoDB shell
# show dbs
# use hospital_management
# db.collections()
# db.sessions.find()
```

### Network Connectivity

```bash
# Test pod-to-pod communication
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# Inside container:
# wget -O- http://hospital-web:5000/healthz

# Test service DNS
kubectl exec -it deployment/hospital-web -n hospital -- nslookup hospital-mongodb
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status and events
kubectl describe pod <pod-name> -n hospital

# Common causes:
# 1. Image pull errors - verify Docker Hub credentials
# 2. Storage issues - check PVC status
# 3. Resource constraints - check node capacity

# Check resource availability
kubectl top nodes
kubectl top pods -n hospital
```

### MongoDB Connection Issues

```bash
# Verify MongoDB pod is running
kubectl get pod -l app.kubernetes.io/component=mongodb -n hospital

# Check MongoDB logs
kubectl logs -f deployment/hospital-mongodb -n hospital

# Test direct connection
kubectl port-forward deployment/hospital-mongodb 27017:27017 -n hospital &
mongosh --host localhost

# Verify ConfigMap and Secret
kubectl get cm hospital-config -n hospital -o yaml
kubectl get secret hospital-secret -n hospital -o yaml
```

### LoadBalancer Not Getting IP

```bash
# AWS NLB provisioning takes 2-5 minutes
kubectl get svc hospital-web -n hospital --watch

# If stuck, check AWS console for Load Balancer status
# aws elb describe-load-balancers

# Force service recreation
kubectl delete svc hospital-web -n hospital
kubectl apply -f k8s/service.yaml -n hospital
```

### Insufficient Storage

```bash
# Check PVC status
kubectl get pvc -n hospital

# Expand PVC (if storage class allows)
kubectl patch pvc hospital-mongodb-data -n hospital \
  -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# Verify expansion
kubectl get pvc hospital-mongodb-data -n hospital
```

## Repository File Placement

| Path | Purpose |
| --- | --- |
| `Dockerfile` | Production multi-stage Node.js container image |
| `.dockerignore` | Removes local, secret, and unnecessary files from Docker build context |
| `k8s/configmap.yaml` | Non-sensitive application configuration |
| `k8s/secret.yaml` | Sensitive application values; replace placeholders before deployment |
| `k8s/pvc.yaml` | AWS EBS gp3 StorageClass and MongoDB PersistentVolumeClaim |
| `k8s/deployment.yaml` | Hospital web Deployment and MongoDB Deployment |
| `k8s/service.yaml` | Public LoadBalancer Service and internal MongoDB ClusterIP Service |
| `hospital-chart/Chart.yaml` | Helm chart metadata |
| `hospital-chart/values.yaml` | Parameterized Helm configuration |
| `hospital-chart/templates/*` | Helm templates for ConfigMap, Secret, PVC, Deployments, and Services |
| `docs/architecture.md` | Deployment architecture and operational notes |
| `Jira/epic.md` | Capstone project epic and objectives |
| `Jira/stories.md` | User stories for each development phase |
| `Jira/subtasks.md` | Detailed subtasks for implementation |
| `Jira/sprint-summary.md` | Summary of completed sprints |

## Production Checklist

Before deploying to production:

### Security
- [ ] Change all default secrets (SESSION_SECRET, JWT_SECRET, ADMIN_PASSWORD)
- [ ] Generate secrets with `openssl rand -hex 32` or strong password generator
- [ ] Enable Kubernetes network policies to restrict traffic
- [ ] Use private ECR registry instead of Docker Hub (optional)
- [ ] Enable Pod Security Standards or Pod Security Policy
- [ ] Rotate secrets regularly

### Scalability
- [ ] Set appropriate resource requests and limits
- [ ] Configure Horizontal Pod Autoscaler (HPA)
- [ ] Test with production-like load
- [ ] Monitor metrics (CPU, memory, disk, network)

### Availability
- [ ] Use multi-zone EKS nodes
- [ ] Configure pod disruption budgets
- [ ] Set up backup for MongoDB data
- [ ] Test disaster recovery procedures
- [ ] Verify readiness and liveness probes are working

### Monitoring & Logging
- [ ] Install CloudWatch Container Insights
- [ ] Configure log aggregation (CloudWatch, ELK, etc.)
- [ ] Set up alerting for critical metrics
- [ ] Monitor application logs for errors
- [ ] Track deployment and upgrade metrics

### Networking
- [ ] Configure AWS VPC for EKS (public/private subnets)
- [ ] Use Network Load Balancer (NLB) for production
- [ ] Enable SSL/TLS termination (at LoadBalancer or Ingress)
- [ ] Restrict security group rules to necessary ports only

### Database
- [ ] Enable MongoDB authentication
- [ ] Configure MongoDB backups (e.g., AWS Backup)
- [ ] Monitor disk usage
- [ ] Plan for data retention policies
- [ ] Test restore procedures

### Deployment Strategy
- [ ] Use Helm for version management
- [ ] Maintain deployment history for rollback
- [ ] Test upgrades in staging environment first
- [ ] Document runbooks for common issues
- [ ] Plan maintenance windows

## Additional Resources

- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Helm Documentation](https://helm.sh/docs/)
- [MongoDB on Kubernetes](https://www.mongodb.com/kubernetes)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Support and Contribution

For issues or contributions, please refer to the project's GitHub repository.

---

**Last Updated:** 2026-05-30  
**Version:** 1.0.0  
**Maintainer:** DevOps Team


## Build Docker Image

Replace `nanineelapu` with your Docker Hub username when required.

```bash
docker build -t nanineelapu/hospital-app:1.0.0 .
docker run --rm -p 5000:5000 \
  -e NODE_ENV=production \
  -e PORT=5000 \
  -e MONGO_URI=mongodb://host.docker.internal:27017/hospital_management \
  -e SESSION_SECRET=local-session-secret \
  -e JWT_SECRET=local-jwt-secret \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=admin123 \
  nanineelapu/hospital-app:1.0.0
```

## Push Docker Image

```bash
docker login
docker push nanineelapu/hospital-app:1.0.0
```

## Deploy with Kubernetes Manifests

Update `k8s/secret.yaml` before applying it.

```bash
kubectl create namespace hospital
kubectl apply -n hospital -f k8s/configmap.yaml
kubectl apply -n hospital -f k8s/secret.yaml
kubectl apply -n hospital -f k8s/pvc.yaml
kubectl apply -n hospital -f k8s/deployment.yaml
kubectl apply -n hospital -f k8s/service.yaml
kubectl rollout status deployment/hospital-mongodb -n hospital
kubectl rollout status deployment/hospital-web -n hospital
kubectl get svc hospital-web -n hospital
```

## Deploy with Helm

Set production secrets from the command line or a private values file that is not committed to Git.

```bash
helm lint hospital-chart
helm upgrade --install hospital-app ./hospital-chart \
  --namespace hospital \
  --create-namespace \
  --set image.repository=docker.io/nanineelapu/hospital-app \
  --set image.tag=1.0.0 \
  --set secret.stringData.SESSION_SECRET="$(openssl rand -hex 32)" \
  --set secret.stringData.JWT_SECRET="$(openssl rand -hex 32)" \
  --set secret.stringData.ADMIN_USERNAME="admin" \
  --set secret.stringData.ADMIN_PASSWORD="<strong-admin-password>"
kubectl rollout status deployment/hospital-app-web -n hospital
kubectl get svc hospital-web -n hospital
```

## Validate Deployment

```bash
kubectl get pods -n hospital
kubectl get pvc -n hospital
kubectl logs deployment/hospital-web -n hospital
kubectl describe svc hospital-web -n hospital
curl http://<load-balancer-dns>/healthz
curl http://<load-balancer-dns>/readyz
```

## Upgrade Image Version

```bash
docker build -t nanineelapu/hospital-app:1.0.1 .
docker push nanineelapu/hospital-app:1.0.1
helm upgrade hospital-app ./hospital-chart -n hospital --set image.tag=1.0.1
kubectl rollout status deployment/hospital-app-web -n hospital
```

## Rollback

```bash
helm history hospital-app -n hospital
helm rollback hospital-app <revision> -n hospital
kubectl rollout status deployment/hospital-app-web -n hospital
```

## Cleanup

```bash
helm uninstall hospital-app -n hospital
kubectl delete namespace hospital
```
