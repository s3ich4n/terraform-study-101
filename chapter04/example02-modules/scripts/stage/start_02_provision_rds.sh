#!/bin/bash
cd ../../stage/data-stores/mysql

terraform init

terraform apply -auto-approve
