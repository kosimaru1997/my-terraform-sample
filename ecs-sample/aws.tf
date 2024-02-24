terraform {
  required_version = "1.7.3"
  backend "s3" {
    bucket = "koshimaru-tfstate"
    key    = "sandbox/terraform.tfstate"
    region = "ap-northeast-1"
  }

}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}