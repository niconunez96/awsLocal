## Setup

- `npm install -g aws-cdk-local aws-cdk`
- `cd infra && npm install`

## Run tests

- `docker-compose up localstack`
- `cdklocal bootstrap`
- `cdklocal deploy`
- `docker-compose run lambdas-integration-tests`
