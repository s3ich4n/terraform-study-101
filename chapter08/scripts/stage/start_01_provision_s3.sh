#!/bin/bash
cd ../../global/s3

terraform init

terraform apply -auto-approve
