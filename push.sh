#!/usr/bin/env bash
# 
# Builds a Docker image and pushes to an AWS ECR repository
#
# Invoked by the terraform-aws-ecr-docker-image Terraform module.
#
# Usage:
#
# # Acquire an AWS session token
# $ ./push.sh . 123456789012.dkr.ecr.us-west-1.amazonaws.com/hello-world latest linux/amd64
#

set -e

source_path="$1"
repository_url="$2"
tag="${3:-latest}"
platform="${4:-linux/amd64}"

docker buildx version >/dev/null

region="$(echo "$repository_url" | cut -d. -f4)"
image_name="$(echo "$repository_url" | cut -d/ -f2)"

(cd "$source_path" && DOCKER_BUILDKIT=1 docker build --pull --platform=${platform} -t "$image_name" .)

aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$repository_url"
docker tag "$image_name" "$repository_url":"$tag"
docker push "$repository_url":"$tag"
