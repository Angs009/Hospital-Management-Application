# Epic: Deploy Hospital Application on AWS EKS

## Epic ID
HOSP-EPIC-001

## Project
Hospital Management System - AWS EKS Capstone Project

## Objective

Deploy the Hospital Management System to AWS EKS using production DevOps practices for containerization, Kubernetes orchestration, persistent storage, Helm-based release management, and deployment documentation.

## Business Value

The hospital team can run a reliable, scalable web application for patient registration, appointment booking, doctor management, admin login, and persistent operational data storage on a enterprise-grade Kubernetes platform with automatic scaling, self-healing, and zero-downtime updates.

## Target Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Application Availability | 99.9% | TBD |
| Mean Time to Recovery (MTTR) | < 5 minutes | TBD |
| Deployment Time | < 10 minutes | TBD |
| Data Loss RTO | 0 minutes | TBD |

## Scope

### In Scope

- Analyze application source code and determine runtime requirements
- Build a production-ready Docker image with security best practices
- Create comprehensive Kubernetes manifests (YAML) for all components
- Push Docker image to Docker Hub with immutable version tags
- Deploy application and MongoDB to AWS EKS cluster
- Expose application through AWS LoadBalancer Service
- Configure persistent MongoDB storage using AWS EBS gp3
- Package deployment as a complete Helm chart
- Document deployment procedures and architecture
- Create JIRA project documentation (epic, stories, subtasks)
- Implement security controls (pod security, RBAC, secrets)
- Configure health checks (readiness and liveness probes)
- Set resource requests and limits for cost optimization

### Out of Scope

- Kubernetes cluster creation (assumed existing)
- AWS account provisioning
- MongoDB replication (single instance)
- Horizontal Pod Autoscaling (HPA) implementation
- Service mesh (Istio, Linkerd)
- Advanced monitoring and logging stack
- SSL/TLS termination at application level

## Acceptance Criteria

### Docker & Registry

- [ ] Docker image builds successfully without errors
- [ ] Image uses Node.js 20 Alpine as base runtime
- [ ] Dependencies installed from package-lock.json (no npm install)
- [ ] Container runs as non-root user (node:node, UID 1000)
- [ ] Build context properly excludes local deps, secrets, and documentation
- [ ] Image is tagged as `nanineelapu/hospital-app:1.0.0`
- [ ] Image is pushed to Docker Hub and publicly accessible
- [ ] Image can be pulled and started: `docker pull nanineelapu/hospital-app:1.0.0`
- [ ] .dockerignore file excludes unnecessary files

### Kubernetes Manifests

- [ ] ConfigMap manifest exists with NODE_ENV, PORT, MONGO_URI
- [ ] Secret manifest exists with SESSION_SECRET, JWT_SECRET, ADMIN credentials, and email credentials
- [ ] PersistentVolumeClaim manifest exists (10 Gi, ReadWriteOnce, ebs-gp3)
- [ ] StorageClass manifest exists (ebs.csi.aws.com, gp3, WaitForFirstConsumer)
- [ ] Hospital web Deployment manifest exists with:
  - [ ] 2 replicas (configurable)
  - [ ] RollingUpdate strategy (maxUnavailable: 0, maxSurge: 1)
  - [ ] Readiness probe (/readyz, 15s initial, 10s period)
  - [ ] Liveness probe (/healthz, 30s initial, 20s period)
  - [ ] Resource requests: 100m CPU, 128Mi memory
  - [ ] Resource limits: 500m CPU, 512Mi memory
  - [ ] Non-root security context (uid 1000)
  - [ ] Read-only root filesystem
  - [ ] Proper labels and selectors
- [ ] MongoDB Deployment manifest exists with:
  - [ ] 1 replica
  - [ ] Recreate strategy
  - [ ] TCP readiness probe on port 27017
  - [ ] TCP liveness probe on port 27017
  - [ ] Volume mount to /data/db
  - [ ] Resource requests: 100m CPU, 256Mi memory
  - [ ] Resource limits: 1000m CPU, 1Gi memory
  - [ ] Non-root user (uid 999)
  - [ ] PVC volume reference
- [ ] Service manifests exist:
  - [ ] hospital-web Service with LoadBalancer type
  - [ ] hospital-web Service annotation for AWS NLB
  - [ ] hospital-web Service port 80 → pod 5000
  - [ ] hospital-mongodb Service with ClusterIP type
  - [ ] hospital-mongodb Service port 27017
- [ ] All labels follow Kubernetes recommended practices
- [ ] All selectors correctly match deployment labels

### Helm Chart

- [ ] Chart.yaml exists with proper metadata
  - [ ] apiVersion: v2
  - [ ] Name: hospital-app
  - [ ] Version: 1.0.0
  - [ ] AppVersion: 1.0.0
  - [ ] Description and keywords
  - [ ] Maintainer information
- [ ] values.yaml contains all configuration parameters:
  - [ ] Image repository, tag, pullPolicy
  - [ ] Replica count for web tier
  - [ ] Service type (LoadBalancer) and annotations
  - [ ] Environment variables (NODE_ENV, PORT, MONGO_URI)
  - [ ] Secret configuration (SESSION_SECRET, JWT_SECRET, etc.)
  - [ ] Readiness and liveness probe settings
  - [ ] Resource requests and limits
  - [ ] Pod security context
  - [ ] Container security context
  - [ ] MongoDB configuration (enabled, image, resources, persistence)
  - [ ] Storage class configuration
- [ ] Helm helper templates (_helpers.tpl) with:
  - [ ] hospital-app.name
  - [ ] hospital-app.fullname
  - [ ] hospital-app.chart
  - [ ] hospital-app.labels
  - [ ] hospital-app.selectorLabels
  - [ ] hospital-app.secretName
  - [ ] hospital-app.mongodbName
  - [ ] hospital-app.mongodbClaimName
- [ ] Deployment template with full parameterization
- [ ] Service template with both web and MongoDB services
- [ ] ConfigMap template with parameterized env vars
- [ ] Secret template with conditional creation
- [ ] PVC template with StorageClass and conditional creation
- [ ] Helm chart installs successfully: `helm install hospital hospital-chart/`
- [ ] Helm chart values can be overridden: `helm install ... --set image.tag=1.1.0`
- [ ] Helm chart upgrades successfully: `helm upgrade hospital hospital-chart/`

### Deployment & Testing

- [ ] Application deploys to EKS without errors
- [ ] ConfigMap is created with correct values
- [ ] Secret is created with correct values
- [ ] PVC is created and bound to EBS volume
- [ ] hospital-web Pods start successfully (2 replicas running)
- [ ] hospital-mongodb Pod starts successfully
- [ ] Readiness probes pass (pods added to service)
- [ ] Liveness probes pass (no pod restarts)
- [ ] LoadBalancer Service gets public IP/DNS name (within 2-5 minutes)
- [ ] Application is accessible via LoadBalancer DNS
- [ ] Health endpoints respond correctly:
  - [ ] GET /healthz returns 200
  - [ ] GET /readyz returns 200 (only when DB connected)
- [ ] API endpoints are accessible and functional
- [ ] MongoDB pod has volume mounted and is writable
- [ ] Data persists after pod restart
- [ ] Rolling updates complete with zero downtime

### Documentation

- [ ] README.md exists with:
  - [ ] Application analysis and overview
  - [ ] Docker build and push instructions
  - [ ] Kubernetes deployment instructions (direct manifests)
  - [ ] Helm deployment instructions
  - [ ] Validation and testing procedures
  - [ ] Troubleshooting guide
  - [ ] Production checklist
  - [ ] File placement reference
- [ ] docs/architecture.md exists with:
  - [ ] System overview and diagram
  - [ ] Component descriptions
  - [ ] Network flow diagram
  - [ ] Availability and scaling considerations
  - [ ] Security architecture
  - [ ] Disaster recovery procedures
  - [ ] Operational tasks
- [ ] Jira documentation complete:
  - [ ] Epic (this document)
  - [ ] User stories with acceptance criteria
  - [ ] Subtasks for implementation
  - [ ] Sprint summary and deliverables

### Security & Best Practices

- [ ] No hardcoded secrets in any files
- [ ] Secret placeholders with clear change instructions
- [ ] Image runs as non-root user
- [ ] No privilege escalation allowed
- [ ] Read-only root filesystem enforced
- [ ] All Linux capabilities dropped
- [ ] Security context defined for all containers
- [ ] Pod security context (seccompProfile) configured
- [ ] Labels follow Kubernetes naming conventions
- [ ] Image versioning is immutable (specific version tags)
- [ ] Resource requests and limits defined for all containers

## Dependencies

### AWS Infrastructure
- EKS cluster (v1.27 or later)
- AWS EBS CSI driver installed
- Adequate IAM permissions for EC2, ECR/DockerHub

### Software Tools
- Docker (build and push)
- kubectl (for deployment)
- Helm (for chart management)
- AWS CLI (for cluster access)

### Source Code
- Hospital Management System GitHub repo
- Node.js application with Express and MongoDB

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|-----------|
| Image pull failures | High | Medium | Test pull after push to Docker Hub |
| EBS provisioning delays | Medium | Low | Use pre-existing EBS snapshot if needed |
| StatefulSet vs Deployment for MongoDB | High | Low | Current design uses Deployment; consider StatefulSet for production |
| Resource constraints | High | Medium | Monitor node capacity, configure HPA |
| Data loss on PVC deletion | High | Low | Enable PVC protection, backup EBS volumes |

## Timeline

### Sprint 1: Source Code Analysis & Docker (3 days)
- Analyze application requirements
- Create production Dockerfile
- Build and test Docker image locally
- Push image to Docker Hub

### Sprint 2: Kubernetes Manifests & EKS Deployment (3 days)
- Create ConfigMap, Secret, PVC manifests
- Create Deployment and Service manifests for web and MongoDB
- Deploy to EKS cluster
- Validate deployments and health checks

### Sprint 3: Helm Chart & Documentation (3 days)
- Create Helm chart structure and templates
- Parameterize all values
- Create Helm templates for all components
- Write comprehensive README and architecture docs
- Complete Jira documentation
- Final validation and testing

## Definition of Done

- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Documentation complete and reviewed
- [ ] All tests passing
- [ ] No security vulnerabilities identified
- [ ] All files committed to Git
- [ ] Ready for production deployment

## Success Criteria

1. **Functional Success:** Application fully operational on EKS with all features accessible
2. **Reliability:** 99.9% uptime with successful failover/recovery
3. **Performance:** Sub-second response times for API endpoints, < 3s page load times
4. **Scalability:** Able to handle 2-5x current load with HPA
5. **Security:** Passes security scan, no hardcoded secrets, non-root execution
6. **Maintainability:** Clear documentation, version control, repeatable deployments

## Budget & Resources

- **Development Time:** 9 days (1 DevOps Engineer)
- **AWS Costs:** Minimal (EKS node group, EBS volume, LoadBalancer) - estimated $100-300/month
- **Tools:** Free (Docker Hub, kubectl, Helm, Git)

## Stakeholder Approval

- **Product Owner:** [TO BE FILLED]
- **Infrastructure Lead:** [TO BE FILLED]
- **DevOps Lead:** [TO BE FILLED]

---

**Epic Status:** Ready for Implementation  
**Priority:** Critical  
**Created:** 2026-05-30  
**Last Updated:** 2026-05-30

