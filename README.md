## Intro
Simple guide to compare Terraform and CDK tools.

## Setup

### CDK
- `npm install -g aws-cdk-local aws-cdk`
- `cd infra && npm install`

### Terraform
- `brew install terraform`
- `pip install terraform-local`

## Run tests

### CDK
- `make up`
- `make cdk-init`
- `make cdk-apply`
- `docker-compose run lambdas-integration-tests`

### Terraform
- `make up`
- `make tf-init`
- `make tf-apply`
- `docker-compose run lambdas-integration-tests`

## IaC tools

