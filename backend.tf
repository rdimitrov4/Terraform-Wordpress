terraform {
  backend "s3" {
    bucket       = "tf-state-wordpress-0fa4859e" # Terraform-Wordpress state file bucket
    key          = "prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    
    # Enable native S3 state locking
    use_lockfile = true 
  }
}
