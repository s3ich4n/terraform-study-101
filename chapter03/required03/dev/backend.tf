terraform {
  backend "s3" {
    bucket         = "s3ich4n-chapter03-ex03-t101study-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-mgmt"
    # encrypt        = true
  }
}
