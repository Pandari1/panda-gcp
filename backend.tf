terraform {
  backend "gcs" {
    bucket  = "learning-487000-terraform-state"
    prefix  = "devops-infra"
  }
}