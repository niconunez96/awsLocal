up:
	docker-compose up -d --build
down:
	docker-compose down

tf-init:
	terraform -chdir=./tf_infra init
tf-plan:
	terraform -chdir=./tf_infra plan
tf-apply:
	terraform -chdir=./tf_infra apply -auto-approve && terraform -chdir=./tf_infra output -json > tf_output.json

cdk-init:
	cd ./infra && cdklocal bootstrap
cdk-diff:
	cd ./infra && cdklocal diff
cdk-apply:
	cd ./infra && cdklocal deploy --outputs-file ../cdk_output.json

cdk-save-env:
	jq .InfraStack cdk_output.json | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > .env	
tf-save-env:
	jq -r 'to_entries|map("\(.key)=\(.value.value|tostring)")|.[]' tf_output.json > .env	
test:
	docker-compose run lambdas-integration-tests
