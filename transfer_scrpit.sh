#!/bin/bash

# Set AWS Account ID and Regions
AWS_ACCOUNT_ID="975050220365" # Replace with your AWS Account ID
SRC_REGION="us-east-1"
DEST_REGION="ap-south-1"

# Authenticate with ECR in both regions
aws ecr get-login-password --region $SRC_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$SRC_REGION.amazonaws.com
aws ecr get-login-password --region $DEST_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$DEST_REGION.amazonaws.com

# List all repositories in the source region
repositories=$(aws ecr describe-repositories --region $SRC_REGION --query 'repositories[*].repositoryName' --output text)

# Loop through each repository
for repo in $repositories; do
    echo "Processing repository: $repo"

    # Ensure the destination repository exists
    aws ecr describe-repositories --repository-names $repo --region $DEST_REGION >/dev/null 2>&1 ||
        aws ecr create-repository --repository-name $repo --region $DEST_REGION

    # List all image tags for the repository
    tags=$(aws ecr list-images --repository-name $repo --region $SRC_REGION --query 'imageIds[*].imageTag' --output text)

    # Loop through each image tag
    for tag in $tags; do
        echo "Copying image: $repo:$tag"

        # Pull image from source region
        docker pull $AWS_ACCOUNT_ID.dkr.ecr.$SRC_REGION.amazonaws.com/$repo:$tag

        # Tag the image for the destination region
        docker tag $AWS_ACCOUNT_ID.dkr.ecr.$SRC_REGION.amazonaws.com/$repo:$tag $AWS_ACCOUNT_ID.dkr.ecr.$DEST_REGION.amazonaws.com/$repo:$tag

        # Push image to destination region
        docker push $AWS_ACCOUNT_ID.dkr.ecr.$DEST_REGION.amazonaws.com/$repo:$tag
    done
done

echo "✅ All images copied successfully!"
