#!/bin/bash

# Authenticate to DockerHub
echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin

# Build the Docker image
docker build -t $DOCKER_IMAGE_NAME:$BUILD_NUMBER .

# Push the image to DockerHub
docker push $DOCKERHUB_USERNAME/$DOCKER_IMAGE_NAME:$BUILD_NUMBER

# Logout from DockerHub
docker logout
