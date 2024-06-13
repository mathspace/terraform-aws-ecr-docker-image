terraform {
  required_version = ">=1"
}

resource "aws_ecr_repository" "repo" {
  name = var.image_name

  image_tag_mutability = var.image_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scan
  }

  tags = merge(
    var.tags,
    tomap({
      "Technology Name" = "Elastic Container Registry"
    })
  )
}

resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag '${var.tag}''",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["${var.tag}"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 2 any images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

}
