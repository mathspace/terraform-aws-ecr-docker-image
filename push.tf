# Calculate hash of the Docker image source contents
data "external" "hash" {
  program = [coalesce(var.hash_script, "${path.module}/hash.sh"), var.source_path]
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
    hash = data.external.hash.result["hash"]
  }

  provisioner "local-exec" {
    command     = "${coalesce(var.push_script, "${path.module}/push.sh")} ${var.source_path} ${aws_ecr_repository.repo.repository_url} ${var.tag}"
    interpreter = ["bash", "-c"]
  }
}

