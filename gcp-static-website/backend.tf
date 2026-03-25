terraform {
  cloud {
    organization = "cloudforge-training"

    workspaces {
      name = "cloudforge-training-workspace"
    }
  }
}