terraform {
  required_version = "1.3.7"
  backend "s3" {
    bucket = "koshimaru-terraform-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }

}

provider "aws" {
  profile = "default"
  region     = "ap-northeast-1"
}