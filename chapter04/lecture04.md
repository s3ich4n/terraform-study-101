# 1장

4주차 강의를 듣고 메모

## 목차

- 강의
- 과제
- Lessons learned
- Tips and tricks

## 강의

### Prerequisites

- [(당근페이) 박병진님 - 확장 가능한 테라폼 코드 관리를 위한 원칙](https://www.youtube.com/watch?v=yWhwZpzJ3no&t=2504s)

### 모듈을 쓰게된 이유?

둘 이상의 환경에서 코드 재사용, 여러 테라폼 리소스를 하나의 논리적 그룹으로 관리하기 위해 사용

E.g., 스테이징, 프로덕션, 로컬개발 시 공통되는 코드는 modules 같은 디렉토리 안에다가 옮겨서 써도 됨

- **분류** : **Root** 모듈(실제로 수행하게 되는 작업 디렉터리의 테라폼 코드 모음) , **Child** 모듈, Published 모듈 - [링크](https://developer.hashicorp.com/terraform/language/modules)
  - Child : 다른 모듈의 테라폼 코드 내에서 호출(참조)하기 위한 목적으로 작성된 테라폼 코드 모음
- **모듈 소스** : Local paths, Terraform Registry, Github, G3 Buckets, GCS buckets 등 - [링크](https://developer.hashicorp.com/terraform/language/modules/sources)
  - Terraform Registry : 하시코프에서 공식적으로 운영하는 테라폼 프로바이더 및 모듈 저장소, 공개된 모듈을 쉽게 활용 가능 - [링크](https://registry.terraform.io/)
    - [Github] terraform-aws-modules : 하시코프 ambassador 중 한 명인 Anton Babenko 가 리드, 가장 인기 있는 AWS 테라폼 모듈을 관리하는 Github 조직 - [링크](https://github.com/terraform-aws-modules)
- **학습 내용** : 모듈 기본 basics, 모듈 입력 inputs, 모듈과 로컬 locals, 모듈 출력 outputs, 모듈 주의 사항 gotchas, 모듈 버전 관리 versioning

### 모듈에 대하여

폴더에 있는 테라폼 코드가 모듈임.

현재 작업 디렉토리의 모듈은 `root` 모듈이라고 한다.

### 모듈 사용시 주의사항

`주의사항` : 파일 경로 File paths, 인라인 블록 Inline blocks

- **파일 경로** File paths : **루트** 모듈에서 **file** 함수 사용은 가능하지만, **별도의 폴더**에 정의된 모듈에서 **file 함수**를 사용하기 위해서 **경로 참조** path reference 표현식 필요
  - path.module : 표현식이 정의된 모듈의 파일 시스템 경로를 반환
  - path.root : 루트 모듈의 파일 시스템 경로를 반환
  - path.cwd : 현재 작업 중인 디렉터리의 파일 시스템 경로를 반환
  - 사용자 데이터 스크립트의 경우 모듈 자체에 상대 경로가 필요하므로 modules/services/webserver-cluster/main.tf 의 templatefile 데이터소스에서 path.module 사용

```terraform
user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })
```

- **인라인 블록** Inline blocks : 일부 테라폼 리소스는 **인라인 블록** 또는 **별도의 리소스**(권장)로 정의 할 수 있음
  - [**인라인 블록]** : **aws_security_group\*\* 리소스에 인라인 블록을 통해 인/아웃 규칙을 정의

```terraform
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}
```

- [별도의 리소스] : aws_security_group 리소스와 aws_security_group_rule 리소스를 통해서 별도로 정의

```terraform
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
```

인라인 블록과 별도의 리소스를 혼합 사용 시 서로 덮어쓰는 오류가 발생함 → **따라서 둘 중 하나만 사용** ⇒ 모듈 작성 시에는 유연성을 위해서 항상 별도의 리소스 사용를 권고

사용 예시 : aws_security_group 의 output variable 정의 `modules/services/webserver-cluster/outputs.tf`

```terraform
output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}
```

이제 스테이징 환경에서 테스트를 위해 추가로 포트를 노출 시, aws_security_group_rule 리소스를 `stage/services/webserver-cluster/main.tf` 에 추가

```terraform
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # (parameters hidden for clarity)
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

인라인 블록으로 규칙을 정의한 경우에는 코드가 작동하지 않음. 유사한 리소스

- aws_security_group and aws_security_group_rule
- aws_route_table and aws_route
- aws_network_acl and aws_network_acl_rule

일일이 다 치는게 유연하다고 한다.

### 모듈 버전관리

- 추가예정

## 실습

- 3주차 실습 코드 내용을 기반으로 책 4장에 나온 모듈을 적용해서 테라폼 코드로 배포해보시기 바랍니다!
  1. s3 버킷부터 생성
  2. prod/stage 를 각각 생성
- 배포 환경이 복잡하다면, 간단한 리소스를 모듈로 만들고 2개의 환경(dev, stg 등)에서 모듈을 참조해서 배포할 수 있게 테스트 해보셔도 좋습니다.

## 과제

1~4주차 내용을 블로깅 후 요약

## Lessons learned

## Tips and tricks
