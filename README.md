# terraform-aws-ecr-docker-image

Terraform module to build & push a Docker image to an AWS ECR repository.

The image can then be used in an AWS Fargate task.

- Builds from a Dockerfile in the source path
- Pushes to an AWS ECR repository
- Can customize the push and hash scripts
- Cleans up old images from the repository

## Requirements

- Docker
- md5sum (e.g. from `brew install md5sha1sum`)

## Usage

See [examples](examples).

## Inputs

| Name        | Description                                        |  Type  |  Default   | Required |
| ----------- | -------------------------------------------------- | :----: | :--------: | :------: |
| hash_script | Path to script to generate hash of source contents | string |    `""`    |    no    |
| image_name  | Name of Docker image                               | string |    n/a     |   yes    |
| push_script | Path to script to build and push Docker image      | string |    `""`    |    no    |
| source_path | Path to Docker image source                        | string |    n/a     |   yes    |
| tag         | Tag to use for deployed Docker image               | string | `"latest"` |    no    |

## Outputs

| Name           | Description                        |
| -------------- | ---------------------------------- |
| hash           | Docker image source hash           |
| repository_url | ECR repository URL of Docker image |
| tag            | Docker image tag                   |
