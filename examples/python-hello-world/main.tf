terraform {
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
