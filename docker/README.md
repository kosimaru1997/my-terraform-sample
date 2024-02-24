# README

## Docker　image push

```sh
docker build . -t koshimaru-sample-image --platform linux/amd64

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com

docker tag koshimaru-sample-image:latest 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com/koshimaru-sample-ecr:latest

docker push 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com/koshimaru-sample-ecr:latest
```

## Login to ECS Task

```sh

aws ecs list-tasks --cluster koshimaru-sample-cluster
TASK_ID=$(aws ecs list-tasks --cluster koshimaru-sample-cluster |jq -r '.taskArns[0]'| sed -e 's/arn.*\///g')

aws ecs execute-command --cluster koshimaru-sample-cluster --task $TASK_ID --container sample-app --interactive --command "/bin/bash"

aws ecs describe-services --cluster koshimaru-sample-cluster --services koshimaru-sample-service
```

