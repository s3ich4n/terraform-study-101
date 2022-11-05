resource "aws_instance" "s3ich4n-ch03-isolation-ec2" {
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"

  tags = {
    Name = "s3ich4n-ch03-isolation-t101-week3"
  }
}

terraform {
  backend "s3" {
    bucket         = "s3ich4n-ch03-isolation-t101study-tfstate-week3"
    key            = "workspaces-default/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week3"
  }
}
