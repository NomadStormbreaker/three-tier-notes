#!/bin/bash

# Set the path to the Dockerfile and the build context directory
DOCKERFILE_PATH="Application-Code/frontend/Dockerfile"
BUILD_CONTEXT="Application-Code/frontend"

# Authenticate to DockerHub
echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin

# Build the Docker image
docker build -t $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$BUILD_NUMBER -f $DOCKERFILE_PATH $BUILD_CONTEXT

# Push the image to DockerHub
docker push $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$BUILD_NUMBER

# Logout from DockerHub
docker logout
