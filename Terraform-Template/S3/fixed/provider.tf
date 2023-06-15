provider "aws" {
  region                   = var.region
  shared_credentials_files = ["C:\\Users\\user1\\.aws\\credentials"]
  profile                  = "test"
}