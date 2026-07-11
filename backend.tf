terraform {
  backend "s3" {
    # These should be passed via -backend-config or hardcoded if appropriate
    # For this task, I will provide the structure as requested
    bucket       = "terraform-state-aws-art" # Replace with your actual bucket name
    key          = "state-art/terraform.tfstate"
    region       = "eu-south-2"
    encrypt      = true
    use_lockfile = true # Terraform 1.10+ native S3 locking
  }
}
