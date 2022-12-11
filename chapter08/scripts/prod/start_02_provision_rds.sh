#!/bin/bash
cd ../../prod/data-stores/mysql

terraform init

terraform apply -auto-approve
