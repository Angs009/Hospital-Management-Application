# Subtasks

## Story 1: Source Code Analysis (Subtasks)

### HOSP-ST1.1: Analyze Backend Package Structure
- **Assignee:** DevOps Engineer
- **Story:** Source Code Analysis
- **Priority:** High
- **Effort:** 2 hours

**Description:**
Inspect backend package.json to identify:
- Main dependencies and versions
- Build tools and npm scripts
- Entry point and start command

**Acceptance Criteria:**
- [ ] package.json reviewed and analyzed
- [ ] Main dependencies documented (express, mongoose, etc.)
- [ ] Start command identified: `node app.js` or `npm start`
- [ ] Database dependency identified: MongoDB + Mongoose
- [ ] Results added to README.md table

**Technical Details:**
```
Dependencies to verify:
- express: ^5.1.0 (web framework)
- mongoose: ^8.17.0 (MongoDB ORM)
- express-session: ^1.18.2 (session management)
- connect-mongo: ^5.1.0 (MongoDB session store)
- bcryptjs: ^2.4.3 (password hashing)
- jsonwebtoken: ^9.0.2 (JWT auth)
- cors: ^2.8.5 (CORS middleware)
- dotenv: ^17.2.1 (env config)
- nodemailer: ^8.0.10 (email)
```

### HOSP-ST1.2: Identify Application Entry Point and Port
- **Assignee:** DevOps Engineer
- **Story:** Source Code Analysis
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Locate and document the Express application entry point and listening port.

**Acceptance Criteria:**
- [ ] Entry point file identified: backend/app.js
- [ ] HTTP listening port identified: 5000
- [ ] CORS configuration verified
- [ ] Session configuration reviewed
- [ ] MongoDB connection string noted: process.env.MONGO_URI

### HOSP-ST1.3: Identify Frontend Serving Path
- **Assignee:** DevOps Engineer
- **Story:** Source Code Analysis
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Identify where the frontend static assets are located and how they are served.

**Acceptance Criteria:**
- [ ] Static files directory identified: public/
- [ ] Frontend structure reviewed:
  - [ ] public/html/ - HTML templates
  - [ ] public/css/ - Stylesheets
  - [ ] public/js/ - JavaScript files
  - [ ] public/images/ - Image assets
- [ ] Express static file serving verified: `app.use(express.static(...))`

### HOSP-ST1.4: Identify MongoDB Dependency and Environment Variables
- **Assignee:** DevOps Engineer
- **Story:** Source Code Analysis
- **Priority:** High
- **Effort:** 2 hours

**Description:**
Review application code for MongoDB connection, environment variables, and configuration requirements.

**Acceptance Criteria:**
- [ ] MongoDB connection string pattern identified: `mongodb://host:port/database`
- [ ] Database name identified: `hospital_management`
- [ ] Environment variables documented:
  - [ ] NODE_ENV (production/development)
  - [ ] PORT (5000)
  - [ ] MONGO_URI (MongoDB connection string)
  - [ ] SESSION_SECRET (session encryption)
  - [ ] JWT_SECRET (token signing)
  - [ ] ADMIN_USERNAME (default admin user)
  - [ ] ADMIN_PASSWORD (admin password)
  - [ ] EMAIL_USER (optional email sender)
  - [ ] EMAIL_PASS (optional email password)
- [ ] dotenv configuration verified

### HOSP-ST1.5: Add Health and Readiness Endpoints
- **Assignee:** DevOps Engineer
- **Story:** Source Code Analysis
- **Priority:** High
- **Effort:** 2 hours

**Description:**
Verify or add health check endpoints required by Kubernetes probes.

**Acceptance Criteria:**
- [ ] `/healthz` endpoint exists (returns 200, Node.js is running)
- [ ] `/readyz` endpoint exists (returns 200 only if MongoDB connected)
- [ ] Both endpoints return JSON with status information
- [ ] Endpoints tested with curl command
- [ ] Response format documented

**Example Response:**
```json
GET /healthz
{
  "status": "ok",
  "uptime": 3600.5,
  "timestamp": "2026-05-30T10:00:00Z"
}

GET /readyz
{
  "status": "ready",
  "database": "connected"
}
```

## Story 2: Docker Containerization (Subtasks)

### HOSP-ST2.1: Create Production Dockerfile
- **Assignee:** DevOps Engineer
- **Story:** Docker Containerization
- **Priority:** Critical
- **Effort:** 3 hours

**Description:**
Create a multi-stage, production-ready Dockerfile with security best practices.

**Acceptance Criteria:**
- [ ] Multi-stage build implemented (dependencies → runtime)
- [ ] Uses Node.js 20 Alpine image (minimal, secure)
- [ ] Dependencies installed from package-lock.json (not npm install)
- [ ] npm ci used for reproducible builds
- [ ] Build stage with all deps, runtime stage with prod only
- [ ] dumb-init installed for proper signal handling
- [ ] Application runs as non-root user (node:node, UID 1000)
- [ ] Working directory set correctly: /app/backend
- [ ] Port 5000 exposed
- [ ] Entry point uses dumb-init: `["dumb-init", "node", "app.js"]`
- [ ] Build tested locally without errors
- [ ] Image size optimized (< 150 MB)
- [ ] dockerfile includes proper labels and metadata

**Key Commands:**
```bash
docker build -t nanineelapu/hospital-app:1.0.0 .
docker history nanineelapu/hospital-app:1.0.0  # Check layer sizes
docker inspect nanineelapu/hospital-app:1.0.0  # Verify user and cmd
```

### HOSP-ST2.2: Create .dockerignore File
- **Assignee:** DevOps Engineer
- **Story:** Docker Containerization
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Create .dockerignore file to exclude unnecessary files from Docker build context.

**Acceptance Criteria:**
- [ ] .dockerignore file created
- [ ] Excludes git metadata (.git, .gitignore)
- [ ] Excludes environment files (.env*)
- [ ] Excludes node_modules (not needed, recreated in container)
- [ ] Excludes documentation (README.md, docs/, Jira/)
- [ ] Excludes Kubernetes configs (k8s/, hospital-chart/)
- [ ] Excludes test files and coverage
- [ ] Excludes CI/CD configs (.github/, .gitlab-ci.yml, etc.)
- [ ] Excludes IDE config (.vscode/, .idea/)
- [ ] Excludes build artifacts and logs

**File Size Optimization:**
- [ ] Dockerfile builds without warnings
- [ ] Build context size minimized (checked with `docker build --progress=plain`)
- [ ] No unnecessary files in final image

### HOSP-ST2.3: Test Image Locally
- **Assignee:** DevOps Engineer
- **Story:** Docker Containerization
- **Priority:** High
- **Effort:** 2 hours

**Description:**
Run and test the Docker image locally to verify functionality.

**Acceptance Criteria:**
- [ ] Image starts without errors: `docker run -p 5000:5000 ...`
- [ ] Container runs as non-root user: verified with `docker exec`
- [ ] Health endpoint responds: `curl http://localhost:5000/healthz`
- [ ] Application logs are clean (no errors, only info logs)
- [ ] Environment variables can be set: `-e MONGO_URI=...`
- [ ] Volume mounting works: `-v /path:/tmp`
- [ ] Signal handling works (graceful shutdown on SIGTERM)

**Test Procedure:**
```bash
# Start container
docker run -d --name test-app \
  -p 5000:5000 \
  -e NODE_ENV=production \
  nanineelapu/hospital-app:1.0.0

# Test
docker exec test-app curl http://localhost:5000/healthz
docker logs test-app | grep "✅"  # Verify startup logs

# Stop
docker stop test-app
docker rm test-app
```

## Story 3: Docker Hub Publishing (Subtasks)

### HOSP-ST3.1: Tag Image for Release
- **Assignee:** DevOps Engineer
- **Story:** Docker Hub Publishing
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Create release tags for Docker image following semantic versioning.

**Acceptance Criteria:**
- [ ] Image tagged as `nanineelapu/hospital-app:1.0.0` (production release)
- [ ] Image tagged as `nanineelapu/hospital-app:v1.0.0` (release version)
- [ ] Image tagged as `nanineelapu/hospital-app:latest` (optional)
- [ ] Tags verified with `docker images` command
- [ ] Tagging commands documented in README

**Commands:**
```bash
docker tag nanineelapu/hospital-app:1.0.0 nanineelapu/hospital-app:v1.0.0
docker tag nanineelapu/hospital-app:1.0.0 nanineelapu/hospital-app:latest
```

### HOSP-ST3.2: Authenticate and Push to Docker Hub
- **Assignee:** DevOps Engineer
- **Story:** Docker Hub Publishing
- **Priority:** Critical
- **Effort:** 1 hour

**Description:**
Login to Docker Hub and push image with all tags.

**Acceptance Criteria:**
- [ ] Docker Hub account exists and is accessible
- [ ] Local docker login successful: `docker login`
- [ ] Image pushed with primary tag: `docker push nanineelapu/hospital-app:1.0.0`
- [ ] Image pushed with version tag: `docker push nanineelapu/hospital-app:v1.0.0`
- [ ] Image available on Docker Hub (verify via web UI)
- [ ] Image can be pulled by others: `docker pull nanineelapu/hospital-app:1.0.0`
- [ ] Push commands documented in README

### HOSP-ST3.3: Document Image Versioning Strategy
- **Assignee:** DevOps Engineer
- **Story:** Docker Hub Publishing
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Document the versioning strategy for future releases.

**Acceptance Criteria:**
- [ ] Semantic versioning explained (MAJOR.MINOR.PATCH)
- [ ] Release tagging documented (e.g., v1.0.0, v1.1.0)
- [ ] Process for updating to next version documented
- [ ] Immutable tag strategy explained
- [ ] How to reference specific versions in Helm charts documented
- [ ] Rollback procedures documented

## Story 4: Kubernetes Deployment (Subtasks)

### HOSP-ST4.1: Create ConfigMap Manifest
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Create Kubernetes ConfigMap manifest for non-sensitive configuration.

**Acceptance Criteria:**
- [ ] k8s/configmap.yaml created
- [ ] Contains NODE_ENV: "production"
- [ ] Contains PORT: "5000"
- [ ] Contains MONGO_URI: "mongodb://hospital-mongodb:27017/hospital_management"
- [ ] Proper labels applied (app.kubernetes.io/* labels)
- [ ] Can be deployed with `kubectl apply -f k8s/configmap.yaml`
- [ ] Verified with `kubectl get cm hospital-config -o yaml`

### HOSP-ST4.2: Create Secret Manifest
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** Critical
- **Effort:** 1 hour

**Description:**
Create Kubernetes Secret manifest for sensitive configuration.

**Acceptance Criteria:**
- [ ] k8s/secret.yaml created
- [ ] Contains placeholder values for secrets
- [ ] Contains SESSION_SECRET with change instruction
- [ ] Contains JWT_SECRET with change instruction
- [ ] Contains ADMIN_USERNAME and ADMIN_PASSWORD
- [ ] Contains EMAIL_USER and EMAIL_PASS (optional)
- [ ] Type: Opaque
- [ ] README documents how to generate secrets
- [ ] Clear warning: "Change all CHANGE_ME values before deployment"
- [ ] Verified with `kubectl get secret hospital-secret -o yaml`

**Secret Generation:**
```bash
SESSION_SECRET=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
echo "SESSION_SECRET=$SESSION_SECRET"
echo "JWT_SECRET=$JWT_SECRET"
```

### HOSP-ST4.3: Create PVC and StorageClass Manifests
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** Critical
- **Effort:** 2 hours

**Description:**
Create PersistentVolume and StorageClass manifests for MongoDB persistence.

**Acceptance Criteria:**
- [ ] k8s/pvc.yaml created
- [ ] StorageClass defined:
  - [ ] Name: ebs-gp3
  - [ ] Provisioner: ebs.csi.aws.com
  - [ ] Volume type: gp3
  - [ ] volumeBindingMode: WaitForFirstConsumer
  - [ ] reclaimPolicy: Retain
  - [ ] allowVolumeExpansion: true
- [ ] PersistentVolumeClaim defined:
  - [ ] Name: hospital-mongodb-data
  - [ ] Size: 10Gi
  - [ ] AccessMode: ReadWriteOnce
  - [ ] StorageClassName: ebs-gp3
- [ ] Labels follow Kubernetes standards
- [ ] Deployment tested to verify PVC binding
- [ ] MongoDB pod successfully mounts volume
- [ ] Write test: data survives pod restart

### HOSP-ST4.4: Create Web Deployment Manifest
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** Critical
- **Effort:** 3 hours

**Description:**
Create Deployment manifest for hospital-web application.

**Acceptance Criteria:**
- [ ] k8s/deployment.yaml created (web section)
- [ ] Deployment name: hospital-web
- [ ] Replicas: 2 (configurable)
- [ ] Strategy: RollingUpdate
  - [ ] maxUnavailable: 0
  - [ ] maxSurge: 1
- [ ] Image: nanineelapu/hospital-app:1.0.0
- [ ] Port: 5000/TCP
- [ ] ConfigMap env injection:
  - [ ] configMapRef: hospital-config
- [ ] Secret env injection:
  - [ ] secretRef: hospital-secret
- [ ] Readiness probe configured:
  - [ ] httpGet: /readyz
  - [ ] initialDelaySeconds: 15
  - [ ] periodSeconds: 10
  - [ ] timeoutSeconds: 3
  - [ ] failureThreshold: 6
- [ ] Liveness probe configured:
  - [ ] httpGet: /healthz
  - [ ] initialDelaySeconds: 30
  - [ ] periodSeconds: 20
  - [ ] timeoutSeconds: 3
  - [ ] failureThreshold: 3
- [ ] Resources defined:
  - [ ] Requests: 100m CPU, 128Mi memory
  - [ ] Limits: 500m CPU, 512Mi memory
- [ ] Security context:
  - [ ] runAsNonRoot: true
  - [ ] runAsUser: 1000
  - [ ] allowPrivilegeEscalation: false
  - [ ] readOnlyRootFilesystem: true
  - [ ] capabilities.drop: [ALL]
- [ ] Volume: tmp emptyDir mounted at /tmp
- [ ] Proper labels applied
- [ ] Deployment tested: pods start and become ready
- [ ] Probes verified: kubectl describe pod shows probe status

### HOSP-ST4.5: Create MongoDB Deployment Manifest
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** Critical
- **Effort:** 3 hours

**Description:**
Create Deployment manifest for MongoDB.

**Acceptance Criteria:**
- [ ] k8s/deployment.yaml created (MongoDB section)
- [ ] Deployment name: hospital-mongodb
- [ ] Replicas: 1
- [ ] Strategy: Recreate
- [ ] Image: mongo:7-jammy
- [ ] Port: 27017/TCP
- [ ] Volume mount: /data/db → PVC (hospital-mongodb-data)
- [ ] Readiness probe:
  - [ ] tcpSocket: port 27017
  - [ ] initialDelaySeconds: 10
  - [ ] periodSeconds: 10
  - [ ] failureThreshold: 6
- [ ] Liveness probe:
  - [ ] tcpSocket: port 27017
  - [ ] initialDelaySeconds: 30
  - [ ] periodSeconds: 20
  - [ ] failureThreshold: 3
- [ ] Resources:
  - [ ] Requests: 100m CPU, 256Mi memory
  - [ ] Limits: 1000m CPU, 1Gi memory
- [ ] Security context:
  - [ ] runAsNonRoot: true
  - [ ] runAsUser: 999
  - [ ] fsGroup: 999
  - [ ] capabilities.drop: [ALL]
- [ ] PVC volume reference correct
- [ ] Pod security context applied
- [ ] Proper labels applied
- [ ] Deployment tested: pod starts and becomes ready
- [ ] Volume attachment verified
- [ ] Database initialization successful

### HOSP-ST4.6: Create Service Manifests
- **Assignee:** DevOps Engineer
- **Story:** Kubernetes Deployment
- **Priority:** Critical
- **Effort:** 2 hours

**Description:**
Create Service manifests for web and MongoDB.

**Acceptance Criteria:**
- [ ] k8s/service.yaml created
- [ ] Web service:
  - [ ] Name: hospital-web
  - [ ] Type: LoadBalancer
  - [ ] Port: 80
  - [ ] TargetPort: 5000
  - [ ] Selector: app.kubernetes.io/name=hospital-application, component=web
  - [ ] Annotation: service.beta.kubernetes.io/aws-load-balancer-type: nlb
  - [ ] Proper labels
- [ ] MongoDB service:
  - [ ] Name: hospital-mongodb
  - [ ] Type: ClusterIP
  - [ ] Port: 27017
  - [ ] TargetPort: 27017
  - [ ] Selector: matches MongoDB deployment
  - [ ] Proper labels
- [ ] Services deployed and verified
- [ ] LoadBalancer gets EXTERNAL-IP (takes 2-5 minutes)
- [ ] DNS name provisioned by AWS
- [ ] ClusterIP service for MongoDB (internal only)
- [ ] Service endpoints point to correct pods

## Story 5: Persistent Storage (Subtasks)

### HOSP-ST5.1: Validate EBS CSI Driver Installation
- **Assignee:** DevOps Engineer
- **Story:** Persistent Storage
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Verify AWS EBS CSI driver is installed on EKS cluster.

**Acceptance Criteria:**
- [ ] EBS CSI driver pods running in kube-system
- [ ] Check: `kubectl get pods -n kube-system | grep ebs-csi`
- [ ] CSI controller running
- [ ] CSI node-agent running on all nodes
- [ ] Driver version compatible with Kubernetes
- [ ] Storage class creation possible

### HOSP-ST5.2: Test PVC Provisioning
- **Assignee:** DevOps Engineer
- **Story:** Persistent Storage
- **Priority:** High
- **Effort:** 2 hours

**Description:**
Test that PVC automatically provisions EBS volumes.

**Acceptance Criteria:**
- [ ] PVC hospital-mongodb-data created successfully
- [ ] PVC status: Bound
- [ ] EBS volume created in AWS (verify in AWS Console)
- [ ] Volume size: 10 Gi
- [ ] Volume type: gp3
- [ ] Pod mounts volume successfully
- [ ] Data written to volume
- [ ] Volume persists after pod restart

**Test Procedure:**
```bash
kubectl apply -f k8s/pvc.yaml
kubectl get pvc
kubectl describe pvc hospital-mongodb-data
# Verify in AWS Console: EC2 > Volumes
```

### HOSP-ST5.3: Test Data Persistence
- **Assignee:** DevOps Engineer
- **Story:** Persistent Storage
- **Priority:** High
- **Effort:** 1 hour

**Description:**
Verify that MongoDB data persists across pod restarts.

**Acceptance Criteria:**
- [ ] MongoDB pod running with volume mounted
- [ ] Write data to MongoDB (insert test collection)
- [ ] Pod restarted: `kubectl delete pod hospital-mongodb-xxx`
- [ ] New pod automatically started
- [ ] Data still present after restart
- [ ] PVC remains bound to same EBS volume
- [ ] No data loss recorded

---

**Last Updated:** 2026-05-30  
**Total Effort:** ~35 hours  
**Remaining Subtasks:** Continue with Story 6 (Helm), Story 7 (Documentation)

