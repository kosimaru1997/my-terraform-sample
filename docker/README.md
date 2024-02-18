# README

## Docker　image push

```sh
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com

docker tag koshimaru-sample-image:latest 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com/koshimaru-sample-ecr:latest

docker push 737600231315.dkr.ecr.ap-northeast-1.amazonaws.com/koshimaru-sample-ecr:latest
```
