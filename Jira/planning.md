# Hospital Application Deployment on AWS EKS

## Epic

### Hospital Application Deployment on AWS EKS

**Objective:**
Deploy the Hospital Application on AWS EKS using production-grade DevOps practices including Docker, Kubernetes, Helm, Persistent Storage, Bastion Host, GitHub PR workflow, and release management.

---

# Sprint 1 - Source Code and Docker Setup

## Story 1: Source Code Analysis and Governance

### Subtasks

* Analyze application source code
* Create GitHub repository structure
* Define branching strategy
* Configure pull request workflow
* Document repository standards

## Story 2: Docker Implementation and Containerization

### Subtasks

* Create Dockerfile
* Build Docker image
* Run container locally
* Validate application functionality
* Optimize Docker image

## Story 3: Docker Hub Image Registry Setup

### Subtasks

* Create Docker Hub repository
* Tag Docker image
* Push image to Docker Hub
* Validate image availability
* Define versioning strategy

---

# Sprint 2 - AWS Infrastructure and Kubernetes

## Story 4: AWS EKS Cluster Setup

### Subtasks

* Create VPC
* Create EKS cluster
* Create worker node group
* Configure kubectl access
* Validate cluster health

## Story 5: Bastion Host Configuration

### Subtasks

* Launch Bastion EC2 instance
* Configure security groups
* Install kubectl
* Install AWS CLI
* Validate secure cluster access

## Story 6: Kubernetes Deployment

### Subtasks

* Create Deployment manifest
* Create Service manifest
* Create ConfigMap
* Create Secret
* Deploy application
* Validate application access

## Story 7: Persistent Storage Implementation

### Subtasks

* Create StorageClass
* Create Persistent Volume Claim
* Attach AWS EBS volume
* Validate data persistence
* Test pod restart recovery

## Story 8: Helm Chart Development

### Subtasks

* Create Helm chart
* Move configurations to values.yaml
* Template Kubernetes manifests
* Validate Helm deployment
* Version Helm chart

---

# Sprint 3 - Release and Documentation

## Story 9: Release Workflow Implementation

### Subtasks

* Define Git workflow
* Configure pull request approvals
* Document deployment process
* Create release checklist
* Validate release process

## Story 10: Project Documentation

### Subtasks

* Create architecture diagram
* Document deployment steps
* Document Kubernetes resources
* Document Helm usage
* Capture screenshots
* Prepare final project report
