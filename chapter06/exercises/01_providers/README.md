# 예제 설명

- IAM role을 생성하여 아래 작업을 수행한다
  - IAM 규칙을 만든다 (EC2 어드민 권한)
  - 해당 규칙을 가진 계정을 생성한다
- ssh key pair 를 생성한다
- 인스턴스를 만들고, 위의 과정에서 만든 key pair를 통해 로그인가능한 EC2 인스턴스를 생성한다.
  - EC2 의 보안규칙을 지정한다.
  - 기본 VPC하에 생성한다.

# 실행방법

1. PEM 키를 만들기 위한 과정
1. 아래 커맨드를 실행하여, IAM role 생성 및 EC2 계정에 사용하도록 한다.

```bash
ssh-keygen -t rsa -b 4096 -f kp-s3ich4n

ssh -i kp-s3ich4n ec2-user@$(terraform output -raw instance_ip)
```
