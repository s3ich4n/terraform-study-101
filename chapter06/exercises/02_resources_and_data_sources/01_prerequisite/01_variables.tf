variable "rdb_cred" {
  default = {
    username = "s3ich4n"
    password = "test-s3ich4n"
  }

  type = map(string)
}
