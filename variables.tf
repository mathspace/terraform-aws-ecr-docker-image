variable "image_name" {
  description = "Name of Docker image"
  type        = string
}

variable "source_path" {
  description = "Path to Docker image source"
  type        = string
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}

variable "hash_script" {
  description = "Path to script to generate hash of source contents"
  type        = string
  default     = ""
}

variable "push_script" {
  description = "Path to script to build and push Docker image"
  type        = string
  default     = ""
}

variable "repository_policy_path" {
  description = "Path to repository policy file"
  type        = string
  default     = null
}

variable "dockerfile_name" {
  description = "Name of the dockerfile within the specified directory"
  type        = string
  default     = "Dockerfile"
}
