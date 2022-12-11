# 이동

cd ~/terraform-up-and-running-code/code/terraform/07-working-with-multiple-providers/examples/multi-account-root
cat main.tf variables.tf

# IAM Role ARN 지정

#export TF_VAR_child_iam_role_arn='arn:aws:iam::<자신의 두번쨰 혹은 세번째 계정 Account ID>:role/<해당 계정의 IAM Role 이름>'
export TF_VAR_child_iam_role_arn='arn:aws:iam::565813864476:role/ma-in-a2'

# 배포 확인

terraform init
terraform plan && terraform apply -auto-approve
Outputs:
child_account_id = "565813864476"
parent_account_id = "911283464785"
