provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.micro"

  tags = {
    Name = "t101-study-renamed"
  }
}
