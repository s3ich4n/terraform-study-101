# 1장

1주차 강의를 듣고 메모

## 목차

* 강의
* 과제
* Lessons Learned
* Tips and tricks

## 강의

### Prerequisites

* Terraform 설치 (on Ubuntu 22.04 LTS)
* AWS 계정 생성
  * 루트계정 MFA 켜기
* AWS IAM User 생성
  * 관리자 권한 주기
  * 프로그래밍 방식 액세스 권한 (Accsss key, Secret key 를 발급받음)
* IAM User 자격증명 세팅

1. Terraform 설치
   1. 해당 링크 참조
      1. 이런거 할 때는 가급적 GPG 인증 등을 통해서 실제 인증된 프로그램을 쓰는지 확인할 것!
      2. 특정 버전을 한 PC에 설치하는 방법은 [공식링크](https://learn.hashicorp.com/tutorials/terraform/install-cli) 참조
      3. 공부하거나 테스트할 때는 [tfenv](https://github.com/tfutils/tfenv) 를 쓰는 것이 좋아보임
        이 링크를 통해서도 GPG 키 인증같은 걸 수행하면서 올바른 값을 가지고 오는지도 확인했다.
2. AWS 계정 생성
   1. 스터디 가이드 참조
3. AWS IAM User 생성
   1. 스터디 가이드 참조
4. IAM User 자격증명 세팅
   1. **(주의!)** 해당 파일은 **절대로** 노출이 되어서는 안됩니다!!!!!! 
   2. [direnv](https://direnv.net/) 를 통해서 하려면? (설치방법은 링크를 따라하면 진행 가능)
      1. 디렉토리 별로 구별할 수 있어서 편함 -> 테라폼용 루트디렉토리에 관련 설정을 줘서 해결
      2. 현재 이 요소를 채택함
   3. [유저 디렉토리에 자격증명 파일을 둬서 하려면?](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-files.html)
      1. 해당 계정으로 쉘을 켜면 별도로 추가설정을 안해줘도 되서 편함

## 내용

### DevOps? IaC?
* DevOps: 소프트웨어를 효율적으로 전달하는 프로세스를 의미
  * 기존에는 Dev 팀과 Ops팀이 따로 있었고, 배포 프로세스 등을 수동으로 진행
  * 클라우드 컴퓨팅의 시대가 도래하고, 기존 환경 및 클라우드 환경에서의 자동화가 도래함... Ops 파트또한 코드로 관리가 가능해짐
  * 폭발적인 성장... Dev와 Ops가 합쳐지며, 이러한 프로세스에 대한 논의 또한 계속해서 이루어짐
  * 업계 또한 기술 발전으로 인한 혜택을 상당부분 누리게 됨
* IaC(Infrastructure as Code): DevOps를 할 수 있게 한 원동력
  * 말 그대로, 인프라를 코드화한 것
  * Ops 파트에 대한 자동화를 할 수 있게끔 한 각종 도구들이 등장
  * 그 중 하나가 앞으로 배우게 될 Terraform(이하 테라폼)임

### 테라폼이란?

* Hashicorp 사가 개발한 IaC 툴
* human-readable conf file을 통해 버저닝, 재사용 및 공유할 수 있도록 함
* 코드화로 인해 가져갈 수 있는 덕목을 모두 사용할 수 있음
* 좋은 코드를 작성하기 위한 요소 또한 적용되어야 함을 의미

### 테라폼 기본 개념

- **resource** : 실제로 생성할 인프라 자원을 의미
- **provider** : 테라폼으로 정의할 Infrastructure Provider를 의미
- **output** : 인프라를 프로비저닝 한 후에 생성된 자원을 output 부분으로 뽑을 수 있음. output으로 추출한 부분은 이후에 remote state에서 활용 가능
- **backend** : 테라폼의 상태를 저장할 공간을 지정하는 부분. backend를 사용하면 현재 배포된 최신 상태를 외부에 저장하기 때문에 다른 사람과의 협업이 가능
- **module** : 공통적으로 활용할 수 있는 인프라 코드를 한 곳으로 모아서 정의하는 부분. Module을 사용하면 변수만 바꿔서 동일한 리소스를 손쉽게 생성할 수 있음
- **remote state** : remote state를 사용하면 VPC, IAM 등과 같이 여러 서비스가 공통으로 사용하는 것을 사용할 수 있음. tfstate파일이 저장되어 있는 backend 정보를 명시하면, terraform이 해당 backend에서 output 정보들을 가져옴

### 테라폼 코드에 대하여

* HCL(Hashicorp Configuration Language) 로 작성함
* OS 마다 **바이너리** 파일이 존재하는데, Go코드는 하나의 바이너리 파일로 컴파일되며 `terraform <args>` 형식의 명령어로 실행
  * 테라폼 바이너리가 AWS/GCP 등의 공급자를 대신해 API를 호출하여 리소스를 생성
  * 테라폼은 인프라 정보가 담겨 있는 테라폼 구성 파일을 생성하여 API를 호출
* 확장자는 `*.tf`

#### 구동방식 (초간단 요약)

* `terraform init` 을 통해 initialize
* `terraform plan` 을 통해 수행하고자 하는 동작을 테스트
* `terraform apply`를 통해 실제 프로비저닝[1]을 수행

* 여기서 잠깐
  * [1] 프로비저닝?
    * -> 실제 코드에 대한 환경을 배포한다는 뜻으로 이해
    * 적절한 권한을 가진 유저가 인프라 구성 명령을 내려서 실제 인프라 구성을 수행하도록 함

#### `Resource` 정의 방법

- `작업디렉토리/chapter01/example01` 참고
- `작업디렉토리/chapter01/example02` 참고
- `작업디렉토리/chapter01/example03` 참고

```terraform
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  [CONFIG ...]
}
```
> - PROVIDER : 'aws' 같은 공급자의 이름
> - TYPE : 'security_group' 같은 리소스의 유형
> - NAME : 리소스의 이름
> - CONFIG : 한개 이상의 arguments

#### 참조에 대하여

- **참조**(reference) 는 코드의 다른 부분에서 값에 액세스 할 수 있게 해주는 표현식
    
* `<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`

- PROVIDER : 'aws' 같은 공급자의 이름
- TYPE : 'security_group' 같은 리소스의 유형
- NAME : 보안 그룹 이름인 'instance' 같은 리소스의 이름
- ATTRIBUTE : 'name' 과 같은 리소스의 인수 중 하나이거나 리소스가 내보낸 속성 중 하나

- 예시1
  - `aws` PROVIDER의 `security_group` TYPE에 대하여
  - instance의 id라는 값을 가져오기 위한 참조예시:
    > `aws_security_group.instance.id`

- 종속성    
  - 하나의 리소스에서 다른 리소스로 **참조**를 추가하면 내재된 **종속성**이 작성됨
  - **테라폼**은 종속성 구문을 분석하여 종속성 그래프를 작성하고, 이를 사용하여 리소스를 생성하는 순서를 **자동**으로 결정함

#### 변수(variables) 파일을 별도로 분리

- `작업디렉토리/chapter01/example04` 참고

- 변수값은 `terraform plan`, `terraform apply` 수행 시 명령 프롬프트에 직접 입력할 수도 있다
- 혹은 기본값 설정을 주어 사용할 수도 있다

## Lessons learned

테라폼 코드와 실제 프로비저닝된 환경의 sync에 대하여

- 싱크가 안맞으면...
  - apply 시 지운다........
- `.tfstate` 상태가 안맞으면?

  - plan 시 생성한다........ -> 바로 에러난다. 없으니까
  - 이는 import 커맨드로 실제환경/`.tfstate` 파일간의 싱크를 맞춘다
    - E.g.,
      - `terraform import aws_s3_bucket.t101study $NICK-t101study-bucket-2`

- IaC 도입 시에는 최대한 코드를 통한 상태가 실제 배포된 프로바이더의 상태가 되도록 맞추는 것이 "상당히" 중요!

### 실무자의 팁

- terraform import는 그다지 신뢰할만한 녀석은 아닌듯.

  - Answers

  > 운영환경에서는 terraform import는 100% 신뢰하지 마세요.
  > 복잡한 인프라 구성에서는 import를 하고 plan 과 apply를 하면
  > 리소스를 destroy 하거나 in-place를 하는 경우가 가끔 있습니다.
  >
  > 그래서 local에 저장하지 않고 S3 같은 오브젝트 스토리지에 오브젝트들에 대해서 버저닝 기능을 활성화해서
  > 사용하시는 것이 권장 입니다.

  > IaC의 선언적 특징때문에 상태 저장에 관한 이슈는 어떤 IaC도구든 다 있습니다. 그렇기 때문에 중앙에서 관리하여 Lock을 걸어 중복 apply를 방어합니다

- s3/dynamodb에 대한 플랜 B도 생각해야함

> s3/dynamodb는 가끔 state가 날아가는 불상사가 있을수 있으니 plan b는 꼭 마련해두세요

- terraform enterprise에 대해...

> 테라폼 엔터프라이즈는 설치형인데 HA 구성이 replicated 솔루션으로 구성되어 있고 라이센스를 활성화 하는 솔루션 또한 replicated의 제품에서 지원되는 기능으로 제공 되고 있어서.
> 직접 관리하려면 replicated 솔루션에 대한 이해도가 있어야 됩니다.

- s3 backend에 대한 다른 사람의 의견

> 저는 2021년부터 s3 backend로 쓰고 있긴한데, 아직 사고는 없었구요. 운영환경에서 걱정된다면 s3 버전관리를 켜놓으면 좀 안심 될 것 같네요
```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0" # 2022-04-15
    }
  }
  backend "s3" {
    bucket = "버킷이름"
    key    = "terraform-backend/저장될파일명"
    region = "ap-northeast-2"
  }
}
```

- GitOps 라는 키워드를 가지고 대화하시는 분들의 의견
  - Questions
    > State 에 대한 GitOps 전략은 잘 안통하려나요? 음
  - Answers
    > state 이외에 동시에 여러 사람이 테라폼 apply를 하게 되면 인프라가 꼬이게 되기 때문에 Locking도 함께 사용을 권장하고 있어서 AWS 라면 s3에 state를 저장하고 dynamodb를 사용해서 locking 관리를 하는게 일반적으로 사용되고 있는 방식입니다.

## 과제

- `작업디렉토리/chapter01/exercises` 디렉토리에 작성되었음

## Tips and tricks

- 리전별로 AMI ID는 다르다!
