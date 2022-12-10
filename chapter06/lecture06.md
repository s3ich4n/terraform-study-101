# 1장

6주차 강의를 듣고 메모

## 목차

- 강의
- 과제
- Lessons Learned
- Tips and tricks

## 강의

### Prerequisites

## 내용

Secrets Management Basics

- 민감 정보(DB암호, API 키, TLS인증서, SSH키, GPG 키 등)값은 프로비저닝될 때 안전하게 관리될 필요가 있습니다.

```terraform
resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = var.db_name

  # DO NOT DO THIS!!!
  username = "admin"
  password = "password"
  # DO NOT DO THIS!!!
}
```

비밀번호를 누구든 알 수 없게 하면 안 된다는 것은 상식이지만, 방법을 모르면 사실상 비밀번호를 노출시키는 것과 다름 없기 때문에, 이를 관리하는 도구를 사용해야합니다.

### 암호관리에 대해 논의해봅시다

`The types of secrets you store` : 3가지 유형, 유형에 따라 관리 방식의 차이가 있음

- Personal secrets : 개인 소유의 암호, 예) 방문하는 웹 사이트 사용자 이름과 암호, SSH 키
- Customer secrets : 고객 소유의 암호, 예) 사이트를 운영하는데 고객의 사용자 이름과 암호, 고객의 개인정보 등 → 해싱 알고리즘 사용
- Infrastructure secrets : 인프라 관련 암호, 예) DB암호, API 키 등 → 암복호화 알고리즘 사용

`The way you store secrets` : 2가지 암호 저장 방식 - 파일 기반 암호 저장 vs 중앙 집중식 암호 저장

- File-based secret stores : 민감 정보를 암호화 후 저장 → 암호화 관련 키 관리가 중요 ⇒ 해결책 : AWS KMS, GCP KMS 혹은 PGP Key
- Centralized secret stores : 일반적으로 데이터베이스(MySQL, Psql, DynamoDB 등)에 비밀번호를 암호화하여 저장, 암호화 키는 서비스 자체 혹은 클라우드 KMS(Key Management Service)를 사용

### A comparison of secret management tools

### 암호관리 도구를 Terraform과 함께 사용하기

어떤 식으로 프로비저닝할 때 민감 정보들이 노출되는지 알아봅시다.

#### 프로바이더에서 노출

`provider` 선언 시 IAM 자격증명 정보를 노출하면 절대 안됩니다! 당장 인식할 수 있는 단점은 두가지입니다:

1. 자격증명 정보가 바로 노출됩니다!
2. 하나의 자격증명만 사용할 수 있습니다!

##### 환경변수를 사용하면?

- 장점
  - 자격증명 정보를 노출하지는 않습니다
- 단점
  - 여전히 PC에 평문으로 저장되어있습니다
  - 단독 자격증명만 사용할 수 있습니다.

##### 유저의 민감정보 유출 방지 방법

여러 서비스들을 사용할 수 있습니다.

1. 1Password/LastPass 등의 서비스 구매 후 사용
1. aws-vault 사용: [Github](https://github.com/99designs/aws-vault) [44bits 소개글](https://www.44bits.io/ko/post/securing-aws-credentials-with-aws-vault)을 참고바랍니다!

사용 예시

```bash
# mac 설치
brew install --cask aws-vault

# 윈도우 설치
choco install aws-vault  # 윈도우 Chocolatey
scoop install aws-vault  # 윈도우 Scoop

# 버전 확인
aws-vault --version
v6.6.0

# 설정
#aws-vault add <PROFILE_NAME>
aws-vault add t101
Enter Access Key Id: (YOUR_ACCESS_KEY_ID)
Enter Secret Key: (YOUR_SECRET_ACCESS_KEY)

# 확인
aws-vault ls
Profile                  Credentials              Sessions
=======                  ===========              ========
default                  -                        -
t101                     t101                     -

# 사용
#aws-vault exec <PROFILE> -- <COMMAND>
aws-vault exec t101 -- aws s3 ls
aws-vault exec --debug t101 -- aws s3 ls

aws-vault exec t101 -- terraform plan
aws-vault exec t101 -- terraform apply
```

`aws-vault` 를 사용하신다면, `~/.aws/credentials` 파일은 지우는게 좋습니다.

##### 기계의 민감정보 유출 방지 방법

프로덕션 레벨에서의 CI/CD 워크플로우 내용은 9장에서 살펴봅니다. 현재는 간단히 어떻게 사용되는지 정도만을 소개합니다.

1. [Providers] CircleCI as a CI server, with stored secrets : CI/CD 플랫폼인 CircleCI 를 통해 테라폼 코드를 실행한다고 가정

- 영구자격증명은 IAM 룰과 다름에 주의합니다! 해당 단점을 없애기 위해 2번 예시를 살펴봅시다.

2. [Providers] EC2 Instance running Jenkins as a CI server, with IAM roles 실습 : EC2에 Jenkins 설치 후 CI서버로 테라폼 코드를 실행한다고 가정 시 IAM roles 활용 - [링크](https://github.com/brikis98/terraform-up-and-running-code/tree/master/code/terraform/06-managing-secrets-with-terraform/ec2-iam-role)

- `chapter06/example01` 디렉토리를 참고바랍니다.

3. [Providers] GitHub Actions as a CI server, with OIDC : Github Actions 은 직접 자격 증명과 OIDC Open ID Connect 지원 (가장 발전되고 이해하면 훨씬 좋은 개념!)

OAuth 2.0를 기반으로 한 발전형 통신이 OIDC(OpenID Connect)입니다. 이걸 사용해서 인증을 수행하는 예시를 살펴봅시다.

OAuth 2.0에 대해 모르신다면 생활코딩의 [OAuth 2.0 역할](https://www.youtube.com/playlist?list=PLuHgQVnccGMA4guyznDlykFJh28_R08Q-) 플레이리스트를 통해 공부하시는 것을 추천드립니다.

(편집하기: 이거 한번 읽어보고 circleCI 해보면 될듯) (이거 플젝하면서 졸업과제로 날먹하면 됨!)

1.  GitHub Actions 룰을 쓰면서 사용하는 예시입니다.

#### 리소스, 데이터소스에서 노출

마찬가지로, 리소스나 데이터소스 배포시에도 민감정보를 노출하면 절대 안됩니다! 이를 보완하기 위한 방법은 3가지가 있겠습니다.

##### 환경변수를 통한 민감정보 유출 방지

- 장점
  - 모든 언어에서 환경변수에 관련 값을 넣어 쓸 수 있습니다
  - 비용이 들지 않습니다.
- 단점
  - 팀원 모두가 환경변수를 수동으로 공유해야 합니다.

##### 암호화된 파일을 통한 민감정보 유출 방지

암호를 파일에 저장 후 버전 관리 → **암호화 키**를 클라우드 공급자 KMS를 통해 안전하게 저장 혹은 PGP 키 사용

> AWS KMS란?
>
> - 암호화는 키를 사용해 평문을 암호문으로 변환하는 프로세스다
> - 동일한 키를 사용해 암호문을 평문으로 변환할 수 있는데, 이를 복호화라고 한다
> - AWS 키 관리 서비스 **KMS**는 공유 하드웨어 보안 모듈HSM 을 사용하면서 **암호화키**를 **생성**하고 **관리**할 수 있게 도와준다
> - CloudHSM은 AWS 내에서 암호화키를 관리할 수 있지만 보안 강화를 위해 전용 HSM을 사용할 수 있는 서비스다
> - 용어 변경 참고 : 기존 Customer Master Key (**CMK**) → AWS **KMS key** 혹은 **KMS key** 로 변경 - [링크](https://docs.aws.amazon.com/kms/latest/developerguide/dochistory.html)

```bash
export ALIAS_SUFFIX=s3ich4n
aws kms create-alias --alias-name alias/$ALIAS_SUFFIX --target-key-id $KEY_ID

# KMS(구 CMK)로 평문을 암호화해보기
echo "Hello 123123" > secret.txt
aws kms encrypt --key-id alias/$ALIAS_SUFFIX --cli-binary-format raw-in-base64-out --plaintext file://secret.txt --output text --query CiphertextBlob | base64 --decode > secret.txt.encrypted


aws kms decrypt --ciphertext-blob fileb://secret.txt.encrypted --output text --query Plaintext | base64 --decode
Hello 123123
```

##### 중앙 집중식 비밀 저장소 서비스 사용을 통한 민감정보 유출 방지

중앙 집중식 비밀 저장소 서비스 사용 - AWS Secrets Manager, Google Secret Manager 등

#### 플랜파일에서 노출

plan 파일안에는 모든 정보가 평문으로 저장되어있습니다. 따라서 두가지 방안을 반드시 사용할 것을 권장합니다.

1. 백엔드 저장소에 저장하는 시점에 암호화
2. 백엔드 액세스에 대한 접근 통제

## Lessons learned

제 6장에서는 아래의 내용을 반드시 기억하셨으면 좋겠습니다.

## 과제

- [완료] 민감정보를 관리하는 테스트를 해보고 스크린샷을 올리기

## Tips and tricks

- 현재 내용 자체를 잘 숙지하고 활용합시다.
