#!/bin/bash
cd ../../stage/s3

terraform init

terraform apply -auto-approve
