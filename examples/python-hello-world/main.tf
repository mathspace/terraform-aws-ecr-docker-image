terraform {
  required_version = "~> 0.12.0"
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-1"
}

module "python-hello-world" {
  source      = "../../"
  image_name  = "python-hello-world"
  source_path = "${path.module}/src"
}

