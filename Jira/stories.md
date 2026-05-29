# User Stories - Hospital Application AWS EKS Deployment

## Story 1: Source Code Analysis

**Story ID:** HOSP-STORY-001  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** Critical  
**Story Points:** 8  
**Sprint:** Sprint 1

### User Story

As a DevOps engineer, I need to analyze the Hospital Application source code so that I can determine the correct runtime, build process, dependencies, and database requirements for containerization and Kubernetes deployment.

### Description

The Hospital Application is a full-stack web application requiring analysis of:
- Backend runtime and package management
- Express.js web server configuration
- Frontend static asset serving
- MongoDB database integration
- Required environment variables
- Health check endpoints

This analysis will inform the Docker image design, Kubernetes manifests, and deployment documentation.

### Acceptance Criteria

- [ ] Application identified as Node.js Express backend with static frontend
- [ ] Runtime: Node.js 20 (LTS)
- [ ] Package manager: npm with package-lock.json
- [ ] Start command: `node backend/app.js`
- [ ] Application port: 5000
- [ ] Database: MongoDB with Mongoose ORM
- [ ] Health endpoints identified: `/healthz`, `/readyz`
- [ ] All environment variables documented
- [ ] Results added to README.md application overview table
- [ ] Source code analysis reviewed and approved

### Technical Acceptance Criteria

- [ ] `package.json` analyzed for all production dependencies
- [ ] `backend/app.js` entrypoint confirmed
- [ ] `public/` directory structure verified (HTML, CSS, JS)
- [ ] Express middleware configuration reviewed (CORS, session, bodyParser)
- [ ] MongoDB connection string pattern: `mongodb://host:port/database`
- [ ] Environment variables required:
  - [ ] NODE_ENV (production/development)
  - [ ] PORT (5000)
  - [ ] MONGO_URI (connection string)
  - [ ] SESSION_SECRET (session encryption key)
  - [ ] JWT_SECRET (token signing key)
  - [ ] ADMIN_USERNAME, ADMIN_PASSWORD
  - [ ] EMAIL_USER, EMAIL_PASS (optional)
- [ ] Health endpoints respond with status and metadata
- [ ] Readiness probe checks MongoDB connectivity

### Definition of Done

- [ ] Source code analysis document created/reviewed
- [ ] All findings documented in README.md
- [ ] Environment variables catalog created
- [ ] Health check endpoints validated
- [ ] Code review completed and approved
- [ ] Team aware of all dependencies and requirements

---

## Story 2: Docker Containerization

**Story ID:** HOSP-STORY-002  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** Critical  
**Story Points:** 13  
**Sprint:** Sprint 1

### User Story

As a DevOps engineer, I need a production-ready Dockerfile so that the Hospital Application can be built into a secure, optimized container image that runs consistently across local development and Kubernetes environments.

### Description

Create a multi-stage Docker image that:
- Uses Node.js 20 Alpine (minimal, secure)
- Installs dependencies from package-lock.json
- Runs as non-root user for security
- Excludes unnecessary files from build context
- Optimizes image size and layer caching
- Includes proper signal handling (dumb-init)
- Exposes port 5000 for the application

The image must pass security scanning and local testing before being pushed to Docker Hub.

### Acceptance Criteria

- [ ] Multi-stage Dockerfile created
- [ ] Dependencies installed in build stage
- [ ] Production image created with runtime dependencies only
- [ ] Image runs as non-root user (node:node, UID 1000)
- [ ] dumb-init installed for proper signal handling
- [ ] Application port 5000 exposed
- [ ] .dockerignore excludes unnecessary files
- [ ] Image builds without warnings or errors
- [ ] Image size optimized (< 150 MB)
- [ ] Image can be tested locally
- [ ] Container gracefully shuts down on SIGTERM

### Technical Acceptance Criteria

- [ ] Base image: `node:20-alpine`
- [ ] Multi-stage build pattern: dependencies → runtime
- [ ] Dependencies install: `npm ci --omit=dev`
- [ ] npm cache cleaned to reduce layer size
- [ ] Working directory: /app/backend
- [ ] Entry point: `dumb-init node app.js`
- [ ] User: `node` (non-root)
- [ ] Labels included (maintainer, version, description)
- [ ] Build context size < 10 MB (verified with docker build output)
- [ ] Layer count minimized (< 15 layers)
- [ ] Security context in place (non-root user)

### Testing Criteria

- [ ] Local build succeeds: `docker build -t test:1.0.0 .`
- [ ] Image runs without errors: `docker run -p 5000:5000 test:1.0.0`
- [ ] Health endpoint responds: `curl http://localhost:5000/healthz`
- [ ] Application logs are clean (no startup errors)
- [ ] Container user is non-root: `docker exec test id`
- [ ] Signal handling works: container stops within 3 seconds

### Definition of Done

- [ ] Dockerfile created and reviewed
- [ ] .dockerignore created and optimized
- [ ] Local testing passed
- [ ] Image builds in < 3 minutes
- [ ] Security review completed
- [ ] Documentation updated with build commands
- [ ] Ready for Docker Hub push

---

## Story 3: Docker Hub Publishing

**Story ID:** HOSP-STORY-003  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** High  
**Story Points:** 5  
**Sprint:** Sprint 1

### User Story

As a release engineer, I need the Docker image pushed to Docker Hub with immutable version tags so that the EKS deployment can pull a stable, versioned image from a centralized registry.

### Description

Build upon the production Dockerfile to:
- Tag the image with semantic version: `nanineelapu/hospital-app:1.0.0`
- Push to Docker Hub public registry
- Verify image accessibility and pull-ability
- Document versioning strategy for future releases
- Create release notes and changelog

The image must be publicly available and ready for EKS to pull on deployment.

### Acceptance Criteria

- [ ] Docker image built locally with version tag
- [ ] Image tagged: `nanineelapu/hospital-app:1.0.0`
- [ ] Docker Hub account accessible
- [ ] Local docker login successful
- [ ] Image pushed to Docker Hub successfully
- [ ] Image visible on Docker Hub web interface
- [ ] Image can be pulled by others: `docker pull nanineelapu/hospital-app:1.0.0`
- [ ] Image metadata and description added to Docker Hub
- [ ] Versioning strategy documented
- [ ] Immutable tagging strategy explained

### Technical Acceptance Criteria

- [ ] Semantic versioning used: MAJOR.MINOR.PATCH (1.0.0)
- [ ] Release tag created: `nanineelapu/hospital-app:v1.0.0`
- [ ] Optional latest tag: `nanineelapu/hospital-app:latest` (use with caution)
- [ ] Push commands documented in README
- [ ] Docker Hub repository URL documented
- [ ] Image digest recorded for verification
- [ ] Pull command tested from clean environment

### Definition of Done

- [ ] Image successfully pushed to Docker Hub
- [ ] Image publicly accessible and verified
- [ ] Versioning strategy documented
- [ ] Release notes created
- [ ] Team notified of image availability
- [ ] Ready for Kubernetes deployment

---

## Story 4: Kubernetes Deployment

**Story ID:** HOSP-STORY-004  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** Critical  
**Story Points:** 21  
**Sprint:** Sprint 2

### User Story

As a platform engineer, I need Kubernetes manifests for the Hospital Application so that it can be reliably deployed to AWS EKS with production controls including load balancing, persistent storage, health checks, and security best practices.

### Description

Create complete Kubernetes YAML manifests for:
- ConfigMap for non-sensitive configuration
- Secret for sensitive values (with instructions to replace)
- StorageClass for AWS EBS gp3 volumes
- PersistentVolumeClaim for MongoDB data persistence
- Hospital Web Deployment (2 replicas, rolling updates)
- MongoDB Deployment (1 replica, persistent storage)
- LoadBalancer Service for public access
- ClusterIP Service for internal MongoDB access

All manifests must include proper labels, selectors, probes, resources, and security contexts.

### Acceptance Criteria

#### ConfigMap
- [ ] ConfigMap manifest created
- [ ] Contains: NODE_ENV, PORT, MONGO_URI
- [ ] Correct labels applied
- [ ] Verified with `kubectl apply` and `kubectl get cm`

#### Secret
- [ ] Secret manifest created
- [ ] Placeholder values with CHANGE_ME warnings
- [ ] Contains: SESSION_SECRET, JWT_SECRET, ADMIN credentials, EMAIL credentials
- [ ] Type: Opaque
- [ ] Documentation on generating secrets
- [ ] Verified with `kubectl apply` and `kubectl get secret`

#### Storage
- [ ] StorageClass created for ebs-gp3
- [ ] PersistentVolumeClaim created (10 Gi)
- [ ] AccessMode: ReadWriteOnce
- [ ] volumeBindingMode: WaitForFirstConsumer
- [ ] Verified PVC binds to EBS volume

#### Hospital Web Deployment
- [ ] Deployment name: hospital-web
- [ ] 2 replicas (configurable)
- [ ] RollingUpdate strategy (maxUnavailable: 0, maxSurge: 1)
- [ ] Image: nanineelapu/hospital-app:1.0.0
- [ ] Port: 5000/TCP
- [ ] ConfigMap env injection
- [ ] Secret env injection
- [ ] Readiness probe: /readyz (15s initial, 10s period, 6 failures)
- [ ] Liveness probe: /healthz (30s initial, 20s period, 3 failures)
- [ ] Resource requests: 100m CPU, 128Mi memory
- [ ] Resource limits: 500m CPU, 512Mi memory
- [ ] Security context: non-root (1000), read-only filesystem
- [ ] Volume: tmp emptyDir at /tmp
- [ ] Proper labels applied
- [ ] Deployment verified running and ready

#### MongoDB Deployment
- [ ] Deployment name: hospital-mongodb
- [ ] 1 replica
- [ ] Recreate strategy
- [ ] Image: mongo:7-jammy
- [ ] Port: 27017/TCP
- [ ] Volume mount: /data/db → PVC
- [ ] Readiness probe: TCP 27017 (10s initial, 10s period, 6 failures)
- [ ] Liveness probe: TCP 27017 (30s initial, 20s period, 3 failures)
- [ ] Resource requests: 100m CPU, 256Mi memory
- [ ] Resource limits: 1000m CPU, 1Gi memory
- [ ] Security context: non-root (999), fsGroup 999
- [ ] Proper labels applied
- [ ] Deployment verified running and ready

#### Services
- [ ] hospital-web Service: LoadBalancer, port 80 → 5000
- [ ] hospital-web Service annotation: AWS NLB
- [ ] hospital-mongodb Service: ClusterIP, port 27017
- [ ] Services verified running
- [ ] LoadBalancer gets external DNS name
- [ ] ClusterIP service provides internal endpoint

### Integration Criteria

- [ ] All manifests deploy without errors: `kubectl apply -f k8s/`
- [ ] ConfigMap applied before deployments
- [ ] Secret applied before deployments
- [ ] PVC applied before MongoDB deployment
- [ ] All pods reach Ready state
- [ ] Web replicas are healthy and load-balanced
- [ ] MongoDB pod connects successfully
- [ ] Health checks pass (readiness/liveness probes)

### Definition of Done

- [ ] All Kubernetes manifests created and reviewed
- [ ] Deployed to EKS cluster and verified working
- [ ] Health checks passing
- [ ] Application accessible via LoadBalancer
- [ ] Data persists in MongoDB
- [ ] Manifests committed to Git
- [ ] Documentation updated
- [ ] Ready for Helm chart creation

---

## Story 5: Persistent Storage Configuration

**Story ID:** HOSP-STORY-005  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** High  
**Story Points:** 8  
**Sprint:** Sprint 2

### User Story

As an application owner, I need MongoDB data persisted on AWS EBS storage so that patient data, appointments, and application state survive pod restarts and node failures.

### Description

Configure persistent storage for MongoDB using:
- AWS EBS gp3 volumes (SSD, high performance)
- Kubernetes PersistentVolumeClaim for dynamic provisioning
- StorageClass with EBS CSI driver
- Proper volume access modes and reclaim policies
- Data protection and backup strategy

### Acceptance Criteria

- [ ] EBS CSI driver verified on EKS cluster
- [ ] StorageClass created: ebs-gp3
- [ ] PersistentVolumeClaim created: hospital-mongodb-data (10 Gi)
- [ ] PVC automatically provisions EBS volume
- [ ] MongoDB pod mounts volume at /data/db
- [ ] Data written to volume survives pod restart
- [ ] Volume metrics accessible in AWS Console
- [ ] Reclaim policy: Retain (data protection)
- [ ] Volume expansion allowed (for future growth)
- [ ] EBS snapshots planned (for backups)

### Technical Criteria

- [ ] StorageClass parameters:
  - [ ] Provisioner: ebs.csi.aws.com
  - [ ] Volume type: gp3
  - [ ] IOPS: 3000 (default)
  - [ ] Throughput: 125 MiB/s (default)
  - [ ] Encrypted: false (optional)
- [ ] PVC parameters:
  - [ ] Size: 10 Gi
  - [ ] AccessMode: ReadWriteOnce
  - [ ] StorageClassName: ebs-gp3
- [ ] EBS volume tags for AWS billing/management
- [ ] Snapshot schedule documented

### Definition of Done

- [ ] Storage infrastructure verified on EKS
- [ ] PVC successfully provisioned and bound
- [ ] Data persistence tested and confirmed
- [ ] Backup strategy documented
- [ ] Monitoring configured for volume metrics
- [ ] Ready for production use

---

## Story 6: Helm Chart Creation

**Story ID:** HOSP-STORY-006  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** Critical  
**Story Points:** 21  
**Sprint:** Sprint 3

### User Story

As a DevOps engineer, I need a complete Helm chart so that the Hospital Application can be deployed, upgraded, and managed in EKS using parameterized, version-controlled Infrastructure as Code that enables repeatable deployments across environments.

### Description

Create a production-ready Helm chart with:
- Chart.yaml with metadata
- Parameterized values.yaml covering all configuration
- Helper templates for naming and labels
- Templates for all Kubernetes resources (Deployment, Service, ConfigMap, Secret, PVC)
- Helm install/upgrade/rollback operations
- Values overrides for different environments

### Acceptance Criteria

- [ ] Chart created in hospital-chart/ directory
- [ ] Chart.yaml with proper metadata
- [ ] values.yaml with all parameters documented
- [ ] _helpers.tpl with proper template functions
- [ ] deployment.yaml template for web and MongoDB
- [ ] service.yaml template for LoadBalancer and ClusterIP
- [ ] configmap.yaml template with env vars
- [ ] secret.yaml template with secrets
- [ ] pvc.yaml template with StorageClass and PVC
- [ ] Helm lint passes without errors
- [ ] Helm template renders correctly
- [ ] Helm install succeeds
- [ ] Helm upgrade succeeds
- [ ] Helm rollback succeeds
- [ ] Default values work out-of-the-box

### Parameterization Criteria

- [ ] Image repository, tag, pullPolicy parameterized
- [ ] Replica counts configurable
- [ ] Service type and port configurable
- [ ] Environment variables all parameterized
- [ ] Secrets parameterized with placeholders
- [ ] Probe settings parameterized
- [ ] Resource requests/limits parameterized
- [ ] MongoDB settings fully parameterized
- [ ] Storage class and size parameterized
- [ ] Labels and annotations configurable

### Helm Operations Criteria

```bash
# Install
helm install hospital hospital-chart/ -n hospital
# Verify
helm status hospital -n hospital
# Get values
helm get values hospital -n hospital
# Upgrade
helm upgrade hospital hospital-chart/ --set image.tag=1.1.0
# Rollback
helm rollback hospital 1
# Uninstall
helm uninstall hospital
```

### Definition of Done

- [ ] Helm chart created and reviewed
- [ ] All templates render without errors
- [ ] Chart successfully installs to cluster
- [ ] All YAML manifests correctly templated
- [ ] Documentation updated with Helm commands
- [ ] Chart versioned and tagged in Git
- [ ] Ready for production use

---

## Story 7: Documentation

**Story ID:** HOSP-STORY-007  
**Epic:** Deploy Hospital Application on AWS EKS  
**Priority:** High  
**Story Points:** 13  
**Sprint:** Sprint 3

### User Story

As a DevOps engineer and operator, I need comprehensive documentation so that the Hospital Application can be deployed, managed, and troubleshot by current and future team members with clear, up-to-date guidance.

### Description

Create complete documentation including:
- README.md: Deployment guide with step-by-step instructions
- docs/architecture.md: System architecture, component overview, operational procedures
- Jira documentation: Epic, stories, subtasks, sprint summary
- Inline code comments for complex configurations
- Troubleshooting guide with common issues and solutions

### Acceptance Criteria

#### README.md
- [ ] Application overview and analysis
- [ ] Docker build and push procedures
- [ ] Kubernetes deployment options (direct manifests and Helm)
- [ ] Validation and testing procedures
- [ ] Troubleshooting guide
- [ ] Production checklist
- [ ] File placement reference
- [ ] Prerequisites and requirements
- [ ] Production best practices

#### Architecture Document
- [ ] System overview diagram
- [ ] Component descriptions and responsibilities
- [ ] Network flow and communication patterns
- [ ] Data persistence strategy
- [ ] Security architecture
- [ ] Availability and scaling considerations
- [ ] Disaster recovery procedures
- [ ] Monitoring and observability
- [ ] Operational tasks (viewing resources, updating, scaling, backups)

#### Jira Documentation
- [ ] Epic: Complete with objectives, scope, acceptance criteria
- [ ] User Stories: 7 stories with detailed descriptions
- [ ] Subtasks: ~30 detailed subtasks for implementation
- [ ] Sprint Summary: Progress and deliverables

### Quality Criteria

- [ ] Documentation is clear and concise
- [ ] All code examples tested and working
- [ ] All command-line examples documented with explanations
- [ ] Screenshots/diagrams included where helpful
- [ ] Links to external resources provided
- [ ] Formatting consistent with Markdown best practices
- [ ] No broken links or references
- [ ] Reviewed for accuracy and completeness

### Definition of Done

- [ ] All documentation created and reviewed
- [ ] Documentation linked from Git
- [ ] Team has read and understood documentation
- [ ] No open questions about deployment procedures
- [ ] Ready for external sharing/handoff

---

**Total User Stories:** 7  
**Total Story Points:** 89  
**Effort Estimate:** 9 days (1 DevOps Engineer)  
**Target Release:** End of Sprint 3

**Last Updated:** 2026-05-30  
**Status:** Ready for Implementation


### Acceptance Criteria

- StorageClass uses AWS EBS CSI driver.
- PVC requests durable storage.
- MongoDB mounts the PVC at `/data/db`.

## Story 6: Helm Packaging

As a DevOps engineer, I need a complete Helm chart so that deployments are repeatable and configurable.

### Acceptance Criteria

- Chart metadata is complete.
- Values are parameterized in `values.yaml`.
- Templates render Kubernetes resources.
- Install, upgrade, and rollback commands are documented.

## Story 7: Deployment Documentation

As a project evaluator, I need complete documentation so that the capstone can be reviewed and reproduced.

### Acceptance Criteria

- README contains build, push, deploy, validate, upgrade, rollback, and cleanup commands.
- Architecture document explains runtime components and traffic flow.
- Jira epic, stories, subtasks, and sprint summary are present.
