# 1장

2주차 강의를 듣고 메모

## 목차

- 강의
- 과제
- Lessons Learned
- Tips and tricks

## 강의

### Prerequisites

- VPC에 대해 학습
- 1주차 도전과제 01번에서 이론적인 부분에 대해 학습하였음.

## 내용

- [데이터 소스 블록](https://developer.hashicorp.com/terraform/language/data-sources)
  - `data` 로 시작하는 블록을 의미
  - 테라폼을 실행할 때마다 provider 별로 가져온 읽기 전용 정보를 의미한다.
  - 데이터 소스를 통하여, Terraform 외부에서 정의되거나 다른 별도의 Terraform 구성에 의해 정의되거나 기능에 의해 수정된 정보를 사용할 수 있다.
  - provider 별로 resource 타입에 대한 값들이 각기 다를 수 있으므로 사용시 참고가 필요하다.

## 데이터 소스 블록 정의 방법

```terraform
data "<PROVIDER>_<TYPE>" "<NAME>" {
  [CONFIG …]
}
```

> - PROVIDER : aws 같은 공급자의 이름
> - TYPE : vpc 같은 사용하려는 데이터 소스의 유형
> - NAME : 테라폼 코드에서 이 데이터 소스를 참조하는 데 사용할 수 있는 식별자
> - CONFIG : 해당 데이터 소스에 고유한 하나 이상의 인수로 구성됨
>   - 예를 들어, aws_vpc 데이터 소스를 사용하여 기본 VPC(default vpc)의 데이터를 사용하는 구문

- 코드예시

```terraform
data "aws_vpc" "default" {
  default = true
}
```

- 데이터 소스에서 값을 가지고 오려면

  - `data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`
  - E.g, aws_vpc 데이터 소스에서 VPC의 ID를 얻으려면?
    - `data.aws_vpc.default.id`

- 다른 데이터 소스와 결합하여 코드를 작성하는 예시

  - E.g, 다른 데이터 소스인 `aws_subnet_ids` 와 결합하여 해당 VPC 내 서브넷을 조회

  ```terraform
  data "aws_subnets" "default" {
    filter {
      name   = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
  }
  ```

  - E.g, `vpc_zone_identifier` 인수를 이용해 `aws_subnet_ids` 데이터 소스에서 서브넷ID를 가져온 후 ASG가 해당 서브넷을 사용하도록 지시

  ```terraform
  resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier  = data.aws_subnets.default.ids

    min_size = 2
    max_size = 10

    tag {
      key                 = "Name"
      value               = "terraform-asg-example"
      propagate_at_launch = true
    }
  }
  ```

## ASG

- [AWS ASG](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html)를 의미

  - EC2 인스턴스 클러스터 시작, 인스턴스 상태 모니터링/교체, 부하에 따른 클러스터 사이즈 조정 등을 자동으로 해줌.
  - 트래픽 양에 따라 클러스터의 적절한 크기를 조절해야함

  - 참고: [AWS에 HA 및 scalable system 구축방법에 대한 링크](https://www.airpair.com/aws/posts/building-a-scalable-web-app-on-amazon-web-services-p1)

- ASG는 시작 구성정보를 참고하여 인스턴스를 생성하는데, 재배포를 한다면 시작구성을 변경할 수 없음.
- 따라서, 리소스 생성, 업데이트, 삭제 방법을 구성하는 수명주기(`lifecycle`) 설정을 추가해야함.
  - `create_before_destroy` 설정을 이 때 사용함.

## ALB

- [AWS ALB](https://docs.aws.amazon.com/ko_kr/elasticloadbalancing/latest/application/introduction.html)를 의미
- 애플리케이션 레벨의 로드밸런서
  - 트래픽을 분산시키고, 외부에 노출시키는 IP 주소를 단일화함
- 그 외에도 AWS에서는 여러 로드밸런서를 배포함

  - NLB (네트워크 로드 밸런서)
    - L4 레벨 트래픽 처리에 적합(TCP, UDP, TLS, etc.)
  - CLB (클래식 로드 밸런서)
    - 레거시 로드밸런서
    - L7, L4 모두 가능하지만 기능이 적음.
    - 필요시 공부하는 편이 좋을 듯 함

- ALB의 주요 구성
  - 리스너
    - 특정 포트, 특정 프로토콜에 대해 수신
  - 리스너 규칙
    - 특정 경로에 대해 어디로 요청을 "대상 그룹"으로 보낼지 정함
  - 대상 그룹
    - 요청을 받는 하나 이상의 서버
