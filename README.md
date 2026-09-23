# Terraform GCP Infrastructure Lab

A hands-on Infrastructure as Code lab demonstrating the design, deployment, automation, security, and lifecycle management of Google Cloud infrastructure using **Terraform**.

This repository documents my progression from Terraform fundamentals to production-style infrastructure practices including **remote state, multi-environment deployments, reusable modules, GitHub Actions CI/CD, Workload Identity Federation, policy checks, security scanning, branch protection, and destructive-change safeguards**.

---

## Overview

The goal of this project was to develop practical Terraform skills by building and operating infrastructure on Google Cloud Platform rather than working only through isolated examples.

The lab evolved through several stages:

- Terraform fundamentals
- Google Cloud resource provisioning
- Variables and outputs
- Resource dependencies
- Reusable modules
- `count` and `for_each`
- Terraform functions
- Lifecycle management
- Importing existing infrastructure
- State management
- Remote state
- Terraform workspaces
- Multi-environment infrastructure
- GitHub Actions CI/CD
- OIDC / Workload Identity Federation
- Security scanning
- Policy-as-Code
- Branch protection
- Production deployment controls
- Destructive-plan detection

The final result is a practical Terraform engineering environment designed around repeatability, security, automation, and safe infrastructure changes.

---

## Architecture

```text
                         GitHub Repository
                                |
                                |
                      Pull Request / Push
                                |
                                v
                     +---------------------+
                     |   GitHub Actions    |
                     +---------------------+
                       |      |       |
                       |      |       |
                       v      v       v
                    fmt     validate  security
                                      scanning
                       |
                       v
                 Terraform Plan
                       |
                Policy / Safety Gates
                       |
                       v
             OIDC / Workload Identity
                       |
                       v
                Google Cloud Platform
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
      DEV           STAGING          PROD
        |
        v
   Terraform-managed
   cloud resources

Terraform State
      |
      v
Google Cloud Storage
Remote Backend
```

---

## Technology Stack

| Area | Technologies |
|---|---|
| Cloud | Google Cloud Platform |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Authentication | Google Workload Identity Federation / OIDC |
| State Management | Google Cloud Storage |
| Version Control | Git / GitHub |
| Security | Trivy, Gitleaks |
| Terraform Quality | `terraform fmt`, `terraform validate`, TFLint |
| Policy / Safety | Policy checks, destructive-plan detection |
| Automation | Bash, GitHub Actions |
| Operating Environment | Linux / Google Cloud Shell |

---

## Google Cloud Environment

The lab was developed primarily in Google Cloud.

Example environment:

```text
GCP Project: lawal-project-84096
Primary Region: europe-west2
Primary Zone: europe-west2-a
```

> Cloud resource IDs, credentials, secrets, and environment-specific values should never be committed directly to source control.

---

## Repository Objectives

This project demonstrates the ability to:

- provision Google Cloud resources using Terraform;
- structure Terraform code for maintainability;
- parameterize infrastructure using variables;
- expose infrastructure information using outputs;
- manage multiple resources dynamically;
- create reusable Terraform modules;
- manage existing resources through Terraform import;
- safely refactor resources using moved blocks;
- use lifecycle rules to control resource behavior;
- store Terraform state remotely;
- isolate environments using Terraform workspaces;
- validate Terraform through CI/CD;
- authenticate GitHub Actions to GCP without static service-account keys;
- scan infrastructure code for security problems;
- prevent unsafe production changes;
- review Terraform plans before deployment.

---

# Terraform Fundamentals

The project began with the Terraform workflow:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Terraform follows a declarative model.

Instead of describing every manual step required to configure infrastructure, the desired state is defined in `.tf` configuration files.

Terraform then determines how to move the current infrastructure toward that desired state.

---

## Typical Terraform Configuration

A simple provider configuration may look like:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```

Values are parameterized instead of being hard-coded.

Example:

```hcl
variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "zone" {
  type    = string
  default = "europe-west2-a"
}
```

---

# Variables and Outputs

Variables make Terraform configurations reusable.

Example:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
}
```

Outputs expose useful information after deployment.

```hcl
output "instance_name" {
  value = google_compute_instance.vm.name
}
```

Benefits include:

- eliminating repeated hard-coded values;
- simplifying environment-specific deployments;
- making modules reusable;
- exposing values to automation pipelines.

---

# Terraform Modules

Reusable modules were introduced to avoid repeating infrastructure definitions.

A typical structure may resemble:

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── modules/
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/
    └── workflows/
```

Modules help separate:

```text
Root Configuration
       |
       +------ Compute Module
       |
       +------ Networking Module
       |
       +------ Other Infrastructure
```

This improves maintainability and allows infrastructure components to be reused across environments.

---

# Dynamic Resource Creation

The lab covered Terraform meta-arguments such as:

## `count`

```hcl
resource "google_compute_instance" "example" {
  count = 2

  name = "server-${count.index}"
}
```

## `for_each`

```hcl
resource "google_compute_instance" "example" {
  for_each = var.instances

  name = each.key
}
```

`for_each` provides better resource identity when managing named infrastructure components.

---

# Terraform Functions

Terraform functions were used to transform and validate configuration data.

Examples include:

```hcl
length()
lookup()
merge()
contains()
toset()
tomap()
upper()
lower()
join()
```

Functions reduce duplication and allow Terraform configuration to respond dynamically to input values.

---

# Resource Lifecycle Management

Terraform lifecycle rules were explored to control how resources behave when configurations change.

Example:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Other lifecycle concepts covered include:

```text
create_before_destroy
ignore_changes
replace_triggered_by
```

These controls are particularly important for production infrastructure.

---

# Importing Existing Infrastructure

Terraform can bring manually created infrastructure under IaC management.

Example workflow:

```bash
terraform import RESOURCE_ADDRESS RESOURCE_ID
```

After import:

```bash
terraform plan
```

is used to compare the Terraform configuration against the actual resource.

The goal is to reach:

```text
No changes.
Your infrastructure matches the configuration.
```

Importing resources demonstrated the difference between:

```text
Terraform configuration
Terraform state
Actual cloud infrastructure
```

All three must remain aligned.

---

# Terraform State

Terraform state tracks the infrastructure Terraform manages.

Initially state may be stored locally:

```text
terraform.tfstate
```

Local state becomes unsuitable when infrastructure is managed collaboratively or through CI/CD.

The lab therefore progressed to remote state.

---

# Remote State on Google Cloud Storage

Terraform state was migrated to a Google Cloud Storage backend.

Example architecture:

```text
Developer / GitHub Actions
          |
          v
      Terraform
          |
          v
 +--------------------+
 | GCS State Backend  |
 +--------------------+
          |
          v
     GCP Resources
```

Benefits include:

- centralized state;
- better recovery;
- environment consistency;
- CI/CD compatibility;
- state version history;
- reduced risk of conflicting local copies.

State storage was hardened using controls such as:

- versioning;
- uniform bucket-level access;
- public access prevention;
- controlled IAM permissions;
- recovery protections.

---

# Terraform Workspaces

Terraform workspaces were used to isolate infrastructure environments.

Example:

```bash
terraform workspace list
```

Create an environment:

```bash
terraform workspace new staging
```

Switch environments:

```bash
terraform workspace select prod
```

The lab used an environment model similar to:

```text
default  -> Development
staging  -> Staging
prod     -> Production
```

This allowed the same Terraform configuration to deploy environment-specific infrastructure.

---

# Multi-Environment Architecture

```text
                    Terraform Code
                         |
                  +------+------+
                  |             |
                  v             v
               Workspace     Variables
                  |
       +----------+----------+
       |          |          |
       v          v          v
      DEV       STAGING     PROD
       |          |          |
       +----------+----------+
                  |
                  v
               Google Cloud
```

Environment-aware configuration prevents infrastructure definitions from being duplicated unnecessarily.

---

# GitHub Actions CI/CD

Terraform validation and planning were automated with GitHub Actions.

The pipeline evolved toward a workflow similar to:

```text
Developer
    |
    v
Feature Branch
    |
    v
Pull Request
    |
    +--> terraform fmt
    |
    +--> terraform validate
    |
    +--> security checks
    |
    +--> terraform plan
    |
    +--> safety / policy checks
    |
    v
Code Review
    |
    v
Protected Main
    |
    v
Approved Deployment
```

---

## Example CI Checks

Typical Terraform CI commands include:

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan
```

Additional tooling can include:

```bash
tflint
trivy config .
gitleaks detect
```

The CI pipeline ensures infrastructure changes are reviewed before deployment.

---

# Keyless Authentication

One of the major security improvements in the lab was moving from persistent credentials toward keyless authentication.

GitHub Actions authenticates to Google Cloud through:

```text
GitHub Actions
      |
      | OIDC token
      v
Google Workload Identity Pool
      |
      v
Workload Identity Provider
      |
      v
GCP Service Account
      |
      v
Google Cloud Resources
```

This approach avoids storing long-lived Google Cloud service-account keys inside GitHub.

Benefits include:

- short-lived credentials;
- reduced secret exposure;
- repository-scoped access;
- easier credential rotation;
- stronger CI/CD security.

---

# IAM and Least Privilege

Cloud automation identities should have only the permissions they require.

The project explored IAM design based on:

```text
Who is calling?
What operation do they require?
Which resources should they access?
Which environment should they control?
```

This reduces the blast radius of compromised automation credentials.

---

# Infrastructure Security Scanning

Security checks were integrated into the Terraform workflow.

Tools used during the learning process included:

### Trivy

Terraform / IaC scanning:

```bash
trivy config .
```

### Gitleaks

Secrets scanning:

```bash
gitleaks detect
```

### TFLint

Terraform quality and linting:

```bash
tflint
```

These checks help identify problems before infrastructure reaches production.

---

# Policy and Production Safety

Production infrastructure requires additional controls beyond `terraform validate`.

The lab introduced concepts such as:

- branch protection;
- mandatory pull-request validation;
- saved Terraform plans;
- approval gates;
- policy checks;
- destructive-plan detection;
- production-specific safeguards.

A production deployment should not be equivalent to:

```bash
terraform apply -auto-approve
```

without controls.

Instead:

```text
Change
  |
  v
Pull Request
  |
  v
Validation
  |
  v
Terraform Plan
  |
  v
Security / Policy Checks
  |
  v
Human Review
  |
  v
Approved Apply
```

---

# Destructive Plan Detection

A key infrastructure safety practice explored in the lab was detecting destructive Terraform operations.

Terraform plan output can contain actions such as:

```text
create
update
replace
destroy
```

Production workflows should treat unexpected destruction as a high-risk event.

The lab therefore incorporated the principle:

> If a Terraform plan contains an unexpected destroy operation, stop the deployment and investigate before applying it.

This is one of the most important operational lessons from the project.

---

# Git Workflow

Infrastructure changes follow the same engineering discipline as application code.

Example:

```bash
git checkout -b feature/network-update

git add .
git commit -m "Add network configuration"
git push origin feature/network-update
```

Then:

```text
Open Pull Request
        |
        v
Terraform CI
        |
        v
Review Terraform Plan
        |
        v
Merge
```

This creates a traceable infrastructure-change history.

---

# Troubleshooting Experience

An important part of the lab was learning to troubleshoot infrastructure rather than simply following successful examples.

Areas investigated included:

- Terraform syntax errors;
- provider configuration problems;
- authentication failures;
- missing project configuration;
- IAM permission errors;
- resource conflicts;
- state mismatches;
- resource imports;
- workspace confusion;
- CI/CD failures;
- OIDC configuration;
- destructive plans;
- branch protection interactions.

The general troubleshooting process used was:

```text
Read exact error
      |
      v
Identify failing layer
      |
      v
Check configuration/state/cloud
      |
      v
Make smallest safe change
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
Verify expected result
```

---

# Important Terraform Commands

Initialize:

```bash
terraform init
```

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

Show state:

```bash
terraform state list
```

Inspect resource state:

```bash
terraform state show RESOURCE
```

Import:

```bash
terraform import RESOURCE_ADDRESS RESOURCE_ID
```

Workspace list:

```bash
terraform workspace list
```

Create workspace:

```bash
terraform workspace new staging
```

Select workspace:

```bash
terraform workspace select prod
```

Show current workspace:

```bash
terraform workspace show
```

---

# Engineering Practices Demonstrated

This repository demonstrates practical experience with:

### Infrastructure as Code

Cloud infrastructure is represented as version-controlled Terraform configuration.

### Reusability

Variables, modules, and dynamic Terraform expressions reduce duplication.

### State Management

Terraform state is stored remotely rather than being dependent on one local machine.

### Environment Separation

Development, staging, and production infrastructure can be managed independently.

### CI/CD

Terraform validation and planning are integrated into GitHub Actions.

### Keyless Cloud Authentication

GitHub Actions uses short-lived federated credentials.

### Security Scanning

Infrastructure configuration is checked before deployment.

### Change Control

Production infrastructure changes require review and controlled deployment.

### Failure Prevention

Unexpected destructive operations are detected before deployment.

---

# Key Lessons

Several engineering lessons emerged from this project:

1. **Terraform state is critical infrastructure.**

   Losing or corrupting state can make infrastructure difficult to manage safely.

2. **Always inspect `terraform plan`.**

   An apply should never be performed blindly.

3. **Remote state is essential for CI/CD.**

4. **Infrastructure code should follow the same review process as application code.**

5. **Long-lived cloud credentials should be avoided where federation is available.**

6. **Production deployments need stronger controls than development deployments.**

7. **Terraform import is useful when infrastructure already exists outside Terraform.**

8. **Modules improve reuse, but unnecessary abstraction can make infrastructure harder to understand.**

9. **Security scanning should happen before infrastructure is deployed.**

10. **Unexpected destroys require investigation, not automatic approval.**

---

# Skills Demonstrated

This project demonstrates practical experience with:

```text
Terraform
Google Cloud Platform
Infrastructure as Code
Google Cloud IAM
Workload Identity Federation
GitHub Actions
CI/CD
Terraform Modules
Terraform Workspaces
Remote State
GCS
Linux
Git
GitHub
TFLint
Trivy
Gitleaks
Policy-as-Code concepts
Infrastructure Security
Cloud Automation
Bash
Troubleshooting
```

---

# Portfolio Context

This repository represents the Terraform and infrastructure engineering foundation that later supported more advanced projects in my portfolio, including:

- secure multi-environment cloud infrastructure;
- Kubernetes and GitOps platforms;
- AWS ECS/Fargate deployments;
- Ansible and Jenkins automation;
- multi-cloud DevSecOps delivery.

GitHub profile:

**[github.com/TheLawal24](https://github.com/TheLawal24)**

---

# Future Improvements

Possible future extensions include:

- dedicated Terraform environments using separate state files;
- automated documentation using `terraform-docs`;
- Open Policy Agent / Conftest policies;
- Checkov integration;
- cost estimation with Infracost;
- automated drift detection;
- scheduled Terraform plans;
- reusable organization-level Terraform modules;
- Terratest infrastructure testing;
- centralized logging and monitoring;
- stronger environment-specific IAM controls.

---

## Author

**Lawal Oladele Sulaiman**

DevOps & Cloud Engineer

AWS | GCP | Terraform | Kubernetes | Docker | CI/CD | GitOps | DevSecOps

GitHub: [TheLawal24](https://github.com/TheLawal24)

---

## Disclaimer

This repository is primarily a hands-on DevOps and cloud engineering lab.

Cloud resources created through Terraform may incur costs. Review every Terraform plan before applying and destroy unused lab resources when they are no longer required.

```bash
terraform plan
terraform destroy
```

---

## License

This repository is intended for educational, portfolio, and infrastructure engineering practice purposes.
