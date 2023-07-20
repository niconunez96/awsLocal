up:
	docker-compose up -d --build
down:
	docker-compose down

tf-init:
	tflocal -chdir=./tf_infra init
tf-plan:
	tflocal -chdir=./tf_infra plan
tf-apply:
	tflocal -chdir=./tf_infra apply -auto-approve && tflocal output -json > ../tf_output.json

cdk-init:
	cd ./infra && cdklocal bootstrap
cdk-apply:
	cd ./infra && cdklocal deploy --outputs-file ../cdk_output.json
