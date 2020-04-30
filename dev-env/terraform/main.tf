# must set environment variable above
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "yama-dev-env-tfstate"
    key = "terraform.tfstate"
  }
}
