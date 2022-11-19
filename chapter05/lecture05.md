# 1장

5주차 강의를 듣고 메모

## 목차

- 강의
- 과제
- Lessons Learned
- Tips and tricks

## 강의

### Prerequisites

## 내용

테라폼을 통해 마치 프로그램을 작성하듯 작성할 수 있습니다. 이번 챕터에서는 아래의 내용을 학습할 예정입니다:

- 반복, 조건문 사용방법
- 무중단 배포에 필요한 요소들 사용방법
- 주의사항

### 반복문

반복문을 학습하며 아래 요소들을 살펴봅시다.

- count 매개변수
- for_each 표현식
- for 표현식
- for 문자열 지시어

#### count 매개변수

1. IAM 사용자 생성예시 (1) count를 사용

```terraform
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "ch05-iam" {
  count = 3
  name  = "s3ich4n.${count.index}"
}
```

- `terraform init` 을 통해 백엔드에 상태 저장을 위한 `.tfstate` 파일을 설정합니다(앞으로 결과는 생략하도록 하겠습니다).

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installed hashicorp/aws v4.39.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

2. IAM 사용자 생성예시 (2) 내장함수와 배열 조회를 통한 사용

```terraform

```

뭔가 이상합니다. 실수하기 쉬운 코드의 냄새가 나요. 이 부분은 제약사항 부분에서 다시 말씀드리겠습니다.

- cf. 모듈에도 count 매개변수를 사용할 수 있습니다.

```terraform

```

- count 매개변수의 제약사항
  - 인라인 블록을 반복할 수는 없습니다.
  - 변경할 때 list를 잘못 쓰면, 모든 리소스를 삭제한 다음 해당 리소스를 처음부터 다시 만듭니다.

#### for_each 표현식

- 리스트 lists, 집합 sets, 맵 maps 를 반복할 수 있습니다.
- 전체 리소스의 여러 복사본 또는 리소스 내 인라인 블록의 여러 복사본, 모듈의 복사본을 생성 할 때 사용할 수 있겠죠.
- `for_each` 구문의 사용법을 알아봅시다.

```terraform
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  for_each = <COLLECTION>

  [CONFIG ...]
}
```

`terraform plan`, `terraform apply` 를 했을 때의 output 값을 살펴봅시다.

`tomap(null) /* of string */` 같은 값들 떄문이라도 output을 통해서 정확히 어떻게 된건지 알아볼 필요가 있겠네요. 모두 알 필요는 없겠습니다만, 필요한 값을 좀더 세부적으로 컨트롤 할 필요가 있다 라고 이해하면 좋겠습니다.

-

### for 표현식

- () 만일 파이썬에 익숙하시다면, list comprehension을 쓴다고 생각하시면 이해가 빠릅니다.
- 파이썬의 `enumerate` 도 되네요.
- 리스트 (lists) 를 반복합니다.

for 구문은 아래와 같이 사용됩니다.

### 조건문

- (스포) 리소스를 조건부로 생성할 때는 count 를 사용할 수 있지만, 그 외 모든 유형의 반복문 또는 조건문에는 for_each 를 사용합니다.

#### count 매개변수 (1): if 문

- `variable` 내의 값을 가지고와서, 마치 삼항 연산자를 사용하듯이 씁니다. 구문은 아래와 같이 씁니다.

```terraform
variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

<CONDITION> ? <TRUE_VAL> : <FALSE_VAL>
```

- 실제 예시를 살펴보면서 작업해봅시다.

```terraform
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  # enable_autoscaling 이라는 값을 사용해서 추가하는 모습입니다.
  # true 인 경우 각각의 aws_autoscaling_schedule 리소스에 대한 count 매개 변수가 1로 설정되므로 리소스가 각각 하나씩 생성됩니다.
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  # false 인 경우 각각의 aws_autoscaling_schedule 리소스에 대한 count 매개 변수가 0로 설정되므로 리소스가 생성되지 않습니다.
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}
```

#### count 매개변수 (2): if-else 구문

#### for_each 및 for 표현식

- 예시 읽고 이해한 내용을 쓰면 될듯

#### if 문자열 지시자

- if 문자열 지시자는 아래와 같이 사용합니다

`%{ if <CONDITION> }<TRUEVAL>%{ endif }`

- CONDITION: boolean으로 평가되는 표현식입니다.
- TRUEVAL: CONDITION이 참이면 렌더링될 표현식입니다.

- if-else 문자열 지시자는 아래와 같이 사용합니다

`%{ if <CONDITION> }<TRUEVAL>%{ else }<FALSEVAL>%{ endif }`

- CONDITION: boolean으로 평가되는 표현식입니다.
- TRUEVAL: CONDITION이 참이면 렌더링될 표현식입니다.
- FALSEVAL: CONDITION이 거짓이면 렌더링될 표현식입니다.

## Lessons learned

제 5장에서는 아래의 내용을 반드시 기억하셨으면 좋겠습니다.

1. 프로그램을 작성하듯 짜기 위한 방안이 있습니다. 반복문, 조건문이 각각 그것입니다.
2. 반복문은 아래와 같은 방법이 있습니다.
3. count 파라미터를 사용하는 방법
4. for_each 구문
5. for 구문

## 과제

- 반복문, 조건문을 사용한 배포 예시를 사용해봅시다.

## Tips and tricks
