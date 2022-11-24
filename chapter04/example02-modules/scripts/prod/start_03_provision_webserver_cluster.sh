#!/bin/bash
cd ../../prod/services/webserver-cluster

terraform init

terraform apply -auto-approve
