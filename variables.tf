variable "image_name" {
  description = "Name of Docker image"
  type        = string
}

variable "image_scan" {
  description = "Enable images scanning after being pushed to the repository"
  type        = string
  default     = "false"
}

variable "image_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
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

variable "tags" {
  description = "Tags to attach to created resources"
  type        = map(any)
  default     = {}
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
