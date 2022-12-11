# 참고사항

해당 장은 terraform up and running 3장의 내용이다.

아래 명령을 통해 테라폼 버전과 코드를 가져와서 학습한다.

```bash
# tfenv를 통한 Terraform 설치
tfenv install 1.2.3
tfenv use 1.2.3

# 코드 클론
git clone https://github.com/brikis98/terraform-up-and-running-code.git .

# .envrc 파일내용 중, 리전 내용을 아래와 같이 수정
export AWS_DEFAULT_REGION=us-east-2

direnv allow
```

상세 내용은 [해당 경로]() 를 참고한다.
