terraform {
  backend "s3" {
    bucket = "vytran-infra"
    key    = "provision/dev-environment.tfstate"
    region = "ap-southeast-1"
  }
}
