aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 975050220365.dkr.ecr.us-east-1.amazonaws.com
docker run -d -p 8086:80 ecs-deploy
docker build -t ecs-deploy:latest ./
docker tag ecs-deploy:t3 975050220365.dkr.ecr.us-east-1.amazonaws.com/sekhar/ecscicd:t3
docker push 975050220365.dkr.ecr.us-east-1.amazonaws.com/sekhar/ecscicd:t3
aws ecs register-task-definition --cli-input-json file://taskdef.json
aws ecs update-service --cluster nginx-ecs --service DevCluster --desired-count 5
aws ecs update-service --cluster DevCluster \
  --service nginx-ecs \
  --task-definition ecs-nginx-task:8
aws ecs describe-services --cluster DevCluster --services nginx-ecs

aws ecs list-tasks --cluster DevCluster
aws ecs list-task-definitions \
  --family-prefix ecs-nginx-task \
  --sort DESC

aws ecs create-service \
  --cluster DevCluster \
  --service-name nginx-ecs \
  --deployment-controller '{"type": "ECS"}' \
  --task-definition ecs-nginx-task \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration '{
      "awsvpcConfiguration": {
        "subnets": ["subnet-019c05df8a5be4917", "subnet-07c0e11e713419f1f", "subnet-0db83d48bdae1a99c"],
        "securityGroups": ["sg-005ca3ee4d25e9806"],
        "assignPublicIp": "ENABLED"
      }
    }'

aws ecs update-service \
  --cluster DevCluster \
  --service nginx-ecs \
  --deployment-controller type=CODE_DEPLOY
