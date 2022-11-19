variable "names" {
  description = "A list of names"
  type        = list(string)
  default     = ["alice", "bob", "charlie"]
}

output "for_directive" {
  # 끝의 endfor directive가 붙는다는 점을 제외하면 쉽게 이해할 수 있을 듯 합니다.
  value = "%{for name in var.names}${name}, %{endfor}"
}

output "for_directive_index" {
  # 파이썬의 enumerate() 을 쓰듯 사용할 수도 있군요!
  value = "%{for i, name in var.names}(${i}) ${name}, %{endfor}"
}

output "for_directive_index_if" {
  value = <<EOF
%{for i, name in var.names}
  ${name}%{if i < length(var.names) - 1}, %{endif}
%{endfor}
EOF
}

output "for_directive_index_if_strip" {
  value = <<EOF
%{~for i, name in var.names~}
${name}%{if i < length(var.names) - 1}, %{endif}
%{~endfor~}
EOF
}

output "for_directive_index_if_else_strip" {
  value = <<EOF
%{~for i, name in var.names~}
${name}%{if i < length(var.names) - 1}, %{else}.%{endif}
%{~endfor~}
EOF
}
