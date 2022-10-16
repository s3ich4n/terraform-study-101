# 1장

## 순서

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

- GitOps 라는 키워드를 가지고 대화하시는 분들의 의견

  - Questions

    > State 에 대한 GitOps 전략은 잘 안통하려나요? 음

  - Answers
    > state 이외에 동시에 여러 사람이 테라폼 apply를 하게 되면 인프라가 꼬이게 되기 때문에 Locking도 함께 사용을 권장하고 있어서 AWS 라면 s3에 state를 저장하고 dynamodb를 사용해서 locking 관리를 하는게 일반적으로 사용되고 있는 방식입니다.

## 과제

- TBA

## Tips and tricks

- 리전별로 AMI ID는 다르다!
