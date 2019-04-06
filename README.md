# terraform-aws-ecr-docker-image

Builds & pushes a Docker image to an AWS ECR repository.

The image can then be used in an ECS or Fargate task.

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

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| hash\_script | Path to script to generate hash of source contents | string | `""` | no |
| image\_name | Name of Docker image | string | n/a | yes |
| push\_script | Path to script to build and push Docker image | string | `""` | no |
| source\_path | Path to Docker image source | string | n/a | yes |
| tag | Tag to use for deployed Docker image | string | `"latest"` | no |

## Outputs

| Name | Description |
|------|-------------|
| hash | Docker image source hash |
| repository\_url | ECR repository URL of Docker image |
| tag | Docker image tag |
