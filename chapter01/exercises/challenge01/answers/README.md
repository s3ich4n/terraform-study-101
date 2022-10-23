# AWS VPC (subnet, IGW 등)을 코드로 배포한 환경에서 EC2 웹서버 배포

제 1번, AWS VPC에 대해 IaC화 후 프로비저닝을 진행하도록 한다.

아울러 해당 내용은 [해당 웹사이트](https://terraform101.inflearn.devopsart.dev/)를 참고하였다.

## VPC 기본개념

- VPC(Virtual Private Cloud)
  - 사용자의 AWS 계정 전용 가상 네트워크
- 서브넷
  - VPC의 IP 주소 범위
  - 특정 Availability Zone 에 속한 네트워크 그룹
  - VPC 내에서도 나눠진 독립적인 네트워크 구역을 의미
- 라우팅 테이블
  - 네트워크 트래픽을 전달할 위치를 결정하는 데 사용됨
  - 라우팅이라는 규칙집합으로 분류됨
  - 트래픽을 규칙에 맞게 전달해주기 위해 필요한 일종의 테이블
  - 여러 서브넷에서 동시에 사용할 수 있으며, 이렇게 연결하는 작업은 Association 이라고 일컬음
- 인터넷 게이트웨이
  - VPC의 리소스와 인터넷 간의 통신을 활성화하기 위해 VPC에 연결하는 게이트웨이
  - 인터넷 게이트웨이는 VPC 내부와 외부 인터넷이 통신하기 위한 게이트웨이 중 하나
  - 인터넷 게이트웨이가 연결된 서브넷은 흔히 public 서브넷 이라고 부름
- NAT 게이트웨이
  - 네트워크 주소 변환을 통해 프라이빗 서브넷에서 인터넷 또는 기타 AWS 서비스에 연결하는 게이트웨이
    - E.g., 필요한 패키지를 다운로드 받을 때
    - E.g., 써드파티 API를 사용하는 경우에는 반드시 인터넷으로 요청을 보내야 할 때
  - 이 때 고정 IP (Elastic IP)를 할당받아야 함. private subnet에서 나가는 요청은 상기 고정IP로 나간다.
- Security Group(이하 보안그룹)
  - 가상 방화벽 역할을 하는 규칙 집합
  - 인스턴스에 대한 인바운드 및 아웃바운드 트래픽을 제어할 수 있다.
- VPC 엔드포인트
  - 인터넷 게이트웨이, NAT 디바이스, VPN 연결 또는 AWS Direct Connect 연결을 필요로 하지 않고 PrivateLink 구동 지원 AWS 서비스 및 VPC 엔드포인트 서비스에 VPC를 비공개로 연결가능
  - VPC의 인스턴스는 서비스의 리소스와 통신하는 데 퍼블릭 IP 주소를 필요로 하지 않음. VPC와 기타 서비스 간의 트래픽은 Amazon 네트워크를 벗어나지 않음.

## VPC 생성

```terraform
provider "aws" {
  region  = "ap-northeast-2"
}

# provider는 AWS, type은 VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "terraform-101"
  }
}
```

## 서브넷 생성

```terraform
provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-c-terraform-101"
  }
}

# Subnet 1 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-b-terraform-101-subnet-1"
  }
}

# Subnet 2 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "second_subset" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "3-2-c-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-c-terraform-101-igw-main"
  }
}
```

## 인터넷 게이트웨이 생성

```terraform
provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-c-terraform-101"
  }
}

# Subnet 1 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-c-terraform-101-subnet-1"
  }
}

# Subnet 2 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "second_subset" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "3-2-c-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-c-terraform-101-igw-main"
  }
}
```

## 라우팅 테이블 생성

```terraform
provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-d-terraform-101"
  }
}

# Subnet 1 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-b-terraform-101-subnet-1"
  }
}

# Subnet 2 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "second_subset" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "3-2-d-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-d-terraform-101-igw-main"
  }
}

# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-d-terraform-101-route-table"
  }
}

# 서브넷과의 연결
# Route table에 서브넷 1을 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# 서브넷과의 연결
# Route table에 서브넷 2를 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.second_subset.id
  route_table_id = aws_route_table.route_table.id
}
```

## 가상 서브넷 생성

```terraform
provider "aws" {
  region = "ap-northeast-2"
}

# Nat Gateway는 Public 서브넷에 위치하지만, 연결은 private 서브넷과 합니다.
# VPC 생성방법
# provider: aws
# type:     vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "3-2-e-terraform-101"
  }
}

# Subnet 1 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-e-terraform-101-subnet-1"
  }
}

# Subnet 2 생성방법
# provider  : aws
# type      : subnet
resource "aws_subnet" "second_subset" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "3-2-e-terraform-101-subnet-2"
  }
}

# Internet Gateway 생성
# provider  : aws
# type:     : internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-e-terraform-101-igw-main"
  }
}

# Route table 생성
# provider  : aws
# type      : route_table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3-2-e-terraform-101-route-table"
  }
}

# 서브넷과의 연결
# Route table에 서브넷 1을 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id = aws_subnet.first_subnet.id

  # 인터넷 게이트웨이와 연결함
  route_table_id = aws_route_table.route_table.id
}

# 서브넷과의 연결
# Route table에 서브넷 2를 연결
# provider  : aws
# type      : route_table_association
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id = aws_subnet.second_subset.id

  # 인터넷 게이트웨이와 연결함
  route_table_id = aws_route_table.route_table.id
}

# Private Subnet 1 생성방법
# provider  : aws
# type      : subnet
# 인터넷 게이트웨이에 연결되어있지 않음!
resource "aws_subnet" "first_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-e-terraform-101-private-subnet-01"
  }
}

# Private Subnet 2 생성방법
# provider  : aws
# type      : subnet
# 인터넷 게이트웨이에 연결되어있지 않음!
resource "aws_subnet" "second_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "3-2-e-terraform-101-private-subnet-02"
  }
}

# NAT Gateway 생성
# AWS Elastic IP도 함께 생성됨에 유의
# Nat Gateway는 Public 서브넷에 위치하지만, 연결은 private 서브넷과 한다.
resource "aws_eip" "nat_01" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_02" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.nat_01.id

  # Nat Gateway는 Public 서브넷에 위치하지만
  # 연결은 private 서브넷과 진행함에 유의
  subnet_id = aws_subnet.first_subnet.id

  tags = {
    Name = "NAT-GW-01"
  }
}

resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.nat_02.id

  subnet_id = aws_subnet.second_subset.id

  tags = {
    Name = "NAT-GW-02"
  }
}
```
