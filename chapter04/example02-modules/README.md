# 모듈 전체 실행 테스트

## 실행순서

1. s3 버킷부터 프로비전

2. prod/stage를 각각 프로비전

### 테스트 방법: production

`$ ./provision.sh`

### 테스트 방법: staging

`$ ./stage_provision.sh`

## 종료순서

1. prod/stage 내리기

2. s3 버킷 내리기

### 테스트 방법: production

`$ ./destroy.sh`

### 테스트 방법: staging

`$ ./stage_destroy.sh`
