# S3 to GCP Replica - Event-Driven Demo

This repository contains a demo for replicating data from an AWS S3 bucket to a GCP Cloud Storage bucket using Terraform and an event-driven workflow.

---

## 🚀 Features

- **Data replication between AWS S3 and GCP Cloud Storage.**
- **Infrastructure management using Terraform.**
- **Automation through a simple and effective `Makefile`.**
- **Cost report generation with Infracost.**

---
## Diagram
![aws-gcp](drawio/s3-to-gcp.drawio.png)

## 📂 Folder Structure

The repository structure is designed to simplify infrastructure organization and management:

```bash
├── 01-aws-s3-origen.tf
├── 02-gcp-storage.tf
├── Makefile
├── README.md
├── drawio
│   ├── s3-to-gcp.drawio
│   └── s3-to-gcp.drawio.png
├── main.tf
├── outputs.tf
├── provider.tf
├── s3-objects
├── terraform.tfvars
└── variables.tf
```
---

## 🛠️ Using the `Makefile`

The `Makefile` simplifies working with Terraform and GCP. Ensure you are on macOS with the required tools installed.

### 📋 Prerequisites

1. **Terraform:** Install from [Terraform CLI](https://www.terraform.io/downloads).
2. **gcloud CLI:** Install from [Google Cloud CLI](https://cloud.google.com/sdk/docs/install).
3. **Infracost (optional):** Install with `brew install infracost`.

### 📝 Global Variables

- `REGION`: Defines the region for resources (`us-central1` by default).

### 🔧 Available Commands

1. **Log in to GCP:**
   ```bash
   make login
   ```
