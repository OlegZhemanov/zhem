# zhem

## Features

### AWS Infrastructure
- VPC setup with three-tier subnet architecture:
  - Public subnet with direct internet access
  - Private subnet with outbound internet access via NAT Gateway
  - Private subnet with no internet access
- Configured security groups for internal communication
- Automated availability zone selection
- DNS support enabled

### GCP Infrastructure
- Development environment configuration in North America Northeast region
- Modular design with separate components for:
  - Network infrastructure
  - Compute resources
  - Data services
- Multi-zone deployment across three availability zones

## Configuration

The infrastructure can be customized through variables defined in `terraform.tfvars` files within each environment directory.

## Prerequisites

- Terraform installed
- Appropriate cloud provider credentials configured
- Access to AWS and/or GCP accounts

## Note

This project appears to be a work in progress, with infrastructure definitions for both AWS and GCP cloud providers, focusing on creating secure and scalable network architectures.