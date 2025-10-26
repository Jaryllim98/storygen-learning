terraform {
  backend "gcs" {
    bucket  = "storygen-terraform-state"
    prefix  = "terraform/state"
  }
}
