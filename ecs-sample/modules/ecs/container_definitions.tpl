[
    {
      "name": "${container_name}",
      "image": "737600231315.dkr.ecr.ap-northeast-1.amazonaws.com/koshimaru-sample-ecr:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "runtimePlatform": {
        "operatingSystemFamily": "LINUX",
        "cpuArchitecture": "ARM64"
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "koshimaru-ecs-sample",
          "awslogs-group": "/ecs/koshimaru-ecs-sample"
        }
      }
    }
]
  