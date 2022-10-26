# 1장

2주차 강의를 듣고 메모

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

## Lessons learned

- TBD

## Tips and tricks

- TBD
