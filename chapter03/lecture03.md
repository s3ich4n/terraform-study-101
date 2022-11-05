# 3장

2주차, 3주차 강의를 듣고 메모

- 2주차: 테라폼 상태 관리
- 3주차: 테라폼 상태파일 격리 방안

## 목차

- 강의
- 과제
- Lessons Learned
- Tips and tricks

## 강의

### Prerequisites

- [AWS S3](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/Welcome.html)
  - 오브젝트를 버킷 단위로 저장하는 클라우드 스토리지
- AWS DynamoDB
  - AWS에서 제공하는 NoSQL 데이터베이스 서버
- 이 서비스들이 나오는 이유?
  - 테라폼의 "상태"를 기록하기 위함

## 내용

### 테라폼의 상태의 필요성

- 테라폼은 기본적으로 생성한 인프라에 대한 정보를 상태파일에 기록함

  - `terraform.tfstate` 파일로 기록됨
  - 상태파일은 프라이빗 API임에 유의!
    - 배포할 때마다 테라폼이 알아서 써줌. 사용자가 건들여선 안됨!

- 프로덕션 레벨에서 팀 단위로 배포하고 하다보면 아래 문제가 발생할 수 있음
  - 상태파일을 저장하는 공유 스토리지 사용 필요
    - 상기 언급한 상태파일을 공유 스토리지에 작업 필요
  - 상태파일에 대한 잠금(Locking)이 필요
    - 한번에 한 명령만 실행되어야함
    - 경쟁 상태(race condition) 방지 필요
  - 상태파일을 격리해야함
    - 개발환경, 테스트환경, 스테이징 환경, 프로덕션 환경 등이 잘 분리되어있어야 함

### 테라폼 상태 공유 방법

1. VCS로 하면?

- push/pull 시 실수로 파일을 빼먹거나 해서 문제가 발생할 수 있음
  - 버그를 잡은 코드가 다시 들어가거나
    그로인해 인프라가 복제되거나, 사라지거나....
- 락을 못걸음
  - `terraform apply` 에 대한 락을 의미
- 시크릿 파일 관리가 곤란함
  - 테라폼의 모든 데이터는 평문으로 쓰임
  - 주요 기밀정보가 평문으로 기록될 수도 있는 여지가 있음

2. 테라폼의 "원격 백엔드"를 사용

- 상태 파일을 원격 저장소에 저장할 수 있음.

  - AWS S3
  - GCP 클라우드 스토리지
  - Azure storage
  - HashiCorp 사의
    - Terraform Cloud (비싸고 좋고 추천받음)
    - Terraform Pro
    - Terraform Enterprise
  - etc.

- 교재에서는 AWS S3와 DynamoDB의 결합을 소개함

### 테라폼 상태파일의 **격리**

제 3장의 예시를 보면, dev, staging 환경을 s3, dynamodb로 분리하긴 했지만 상태파일 자체가 단일인 상황은 막을 수 없다. 따라서, 상태 격리에 대해서는 두가지 접근법을 함께 사용하기를 권장한다.

1. 테라폼의 Workspace라는 개념

- 복수개의/분리된/이름이 지정된 워크스페이스를 만들 수 있다.

2. 분리된 파일 레이아웃 지정

- 개발환경, 스테이징 환경, 실제 프로덕션 환경(!)에 대한 분리를 통해 실수를 방지할 수 있다.

#### Terraform Workspace에 대하여

- 테라폼의 기본 워크스페이스는 `default` 임

  - **다른 작업 공간으로 전환**하는 것은 **상태 파일이 저장된 경로를 변경**하는 것과 같음
  - 작업 공간은 코드 리팩터링 code refactoring 을 시도하는 것 같이 이미 **배포되어 있는 인프라에 영향을 주지 않고 테라폼 모듈을 테스트** 할 때 유용함
  - 즉 새로운 작업 공간을 생성하여 완전히 **동일한 인프라의 복사본을 배포**할 수 있지만 상태 정보는 별도의 파일에 저장함

- 단점?
  1. 모든 작업 공간의 상태 파일은 동일한 백엔드(예. 동일한 S3 버킷)에 저장. 모든 작업 공간이 동일한 인증과 접근 통제를 사용.
     - E.g., 검증과 운영 환경이 다른 백엔드를 사용하고, 해당 백엔드에 다른 보안 수준의 통제 설정이 불가능함
  2. 코드나 터미널에 현재 작업 공간에 대한 정보가 표시 되지 않음. 코드 탐색 시 한 작업 공간에 배치된 모듈은 다른 모든 작업 공간에 배치된 모듈과 동일
     -> 이로 인해 인프라를 제대로 파악하기 어려워 유지 관리가 어려움
  3. 위 두 항목의 결합된 문제가 발생 할 수 있음. 예를 들면 검증 환경이 아닌 운영 환경에서 `terraform destroy` 명령을 실행 할 수 있음(!).
     - 검증과 운영 환경이 동일한 인증 매커니즘을 사용하기 때문에 위 오류에서 보호할 방법이 없음
  4. 따라서 **파일 레이아웃**을 이용한 격리를 권장!

#### 파일 레이아웃 분리에 대하여

- 테라폼 프로젝트를 생성하여, 파일 레이아웃을 잡음.

  - 각 구성파일을 분리된 폴더에 넣음 (E.g., staging, production, etc.)
  - 각 환경에 서로 다른 백엔드 환경 구성 (E.g., S3 버킷 백엔드의 AWS 계정분리)(이럴 때 direnv가 좋은 역할을 하겠군! 더 나아가서 AWS Secrets Manager 계정도 같이 분리하는 편이 더 낫겠군)

- 예시
  `최상위 폴더`

  - **stage** : 테스트 환경과 같은 사전 프로덕션 워크로드 workload 환경
  - **prod** : 사용자용 맵 같은 프로덕션 워크로드 환경
  - **mgmt** : 베스천 호스트 Bastion Host, 젠킨스 Jenkins 와 같은 데브옵스 도구 환경
  - **global** : S3, IAM과 같이 모든 환경에서 사용되는 리소스를 배치

  `각 환경별 구성 요소`

  - **vpc** : 해당 환경을 위한 네트워크 토폴로지
  - **services** : 해당 환경에서 서비스되는 애플리케이션, 각 앱은 자체 폴더에 위치하여 다른 앱과 분리
  - **data-storage** : 해당 환경 별 데이터 저장소. 각 데이터 저장소 역시 자체 폴더에 위치하여 다른 데이터 저장소와 분리

  `명명 규칙 naming conventions` (예시)

  - **variables.tf** : 입력 변수
  - **outputs.tf** : 출력 변수
  - **main-xxx.tf** : 리소스 → 개별 테라폼 파일 규모가 커지면 특정 기능을 기준으로 **별도 파일**로 분리 (ex. main-iam.tf, main-s3.tf 등) 혹은 **모듈** 단위로 나눔
  - **dependencies.tf** : 데이터 소스
  - **providers.tf** : 공급자

- 실습구성
  - TBD (`tree` 로 그리기)

##### 백엔드 리소스 배포 (1): S3 버킷 생성

##### 백엔드 리소스 배포 (2): RDS 생성

- 리소스에 전달해야 되는 매개변수 중 **패스워드** 처럼 **민감정보**는 코드에 직접 **평문 입력을 하는 대신 전달 할 수 있는 방안**
  - 다양한 **시크릿 저장소 활용** : aws secret manager, aws ssm parameter, GCP kms 와 kms secrets, Azure Key Vault 와 vault secret 등
    - 최소한의 일만 하는 계정을 만들기: 분리와 역할, 필요하면 추가
      - 스테이징: 스테이징 프로비저닝에 필요한 AWS 서비스 일부만 허용
      - 프로덕션: 상기 내용과 마찬가지(내가 모르는 추가적인 보안허용 등이 있는지도 확인해보기)
  - 테라폼 **외부에서 환경 변수**를 통해 시크릿 값을 테라폼에 전달 : `**export** TF_VAR_db_password=”(YOUR_DB_PASSWORD)”` , **윈도우** `**set** TF..`

##### 웹서버 클러스터 배포 (1): `terraform_remote_state` 란?

- 백엔드에 상태 파일(DB 정보)를 읽어서 웹 서버 클러스터 구성 ⇒ 변환 데이터는 읽기 전용
- 모든 데이터베이스의 출력 변수는 상태 파일에 저장되며 아래와 같은 형식의 속성 참조를 이용해 `terraform_remote_state` 데이터 소스에서 읽을 수 있음

> `data.terraform_remote_state.<NAME>.outputs.<ATTRIBUTE>`

- 아래 예제는 **terraform_remote_state 데이터 소스** 에서 데이터베이스 주소와 포트 정보를 가져와서 HTTP 응답에 정보를 노출

```bash
user_data = <<EOF
#!/bin/bash
echo "Hello, World" >> index.html
echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
nohup busybox httpd -f -p ${var.server_port} &
EOF
```

- **사용자 데이터 스크립트**가 길어지면 인라인으로 정의가 복잡해짐 → 외부화 : **내장 함수**와 `template_file` 데이터 소스 사용
- 테라폼에는 표현식을 사용하여 실행할 수 있는 여러 내장 함수 built-in function 이 있음

> `function_name()`

- 예를 들면 format 함수는 아래 처럼 사용, 이 함수는 문자열 FMT의 `sprintf` 구문에 따라 `ARGS` 인수를 형식화함

> `format(<FMT>, <ARGS>, ...)`

- 내장 함수 테스트하는 방법은 테라폼 console 실행 후 대화형 콘솔을 사용해서 질의한 결과를 바로 확인
- 테라폼 콘솔은 읽기 전용으로 실수로 인프라나 상태가 변경하지 않을지 걱정하지 않아도 됨

```bash
# 참고: 테라폼 콘솔 사용에 관하여
terraform console
> format("%.3f", 3.14159265359)
"3.142"
```

- 테라폼에는 문자열, 숫자, 리스트, 맵 등을 조작하는 데 사용할 수 있는 많은 내장 함수가 존재. 그 중 `templatefile` 함수 살펴보기
- `templatefile` 함수는 PATH 에서 파일을 읽고 그 내용을 문자열로 반환

> `templatefile(<PATH>, <VARS>)`

- E.g., 스크립트 파일을 넣고 stage/services/webserver-cluster/user-data.sh 파일을 넣고 문자열로 내용을 읽을 수 있음

```bash
#!/bin/bash

cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p ${server_port} &
```

- 사용자 데이터 스크립트에 동적인 데이터는 참조와 보간을 활용. 아래는 ASG 코드 예시
- `templatefile` 데이터 소스의 vars 맵에 있는 변수만 사용 가능

```bash
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0fb653ca2d3203ac1"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  # Render the User Data script as a template
  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}
```

## Lessons learned

- TBD

## Tips and tricks

- 테라폼 코드를 작성할 때도 컨벤션을 지키자

  - [테라폼 컨벤션](https://developer.hashicorp.com/terraform/language/syntax/style)

- 테라폼에서 뭔가 내용을 수정하거나 할 때...
  - 기존 서비스를 지우고 다시 생성한다..!
  - 깨지면, 복구는 안되는 건가요? -> apply를 여러번 해야하는군요
