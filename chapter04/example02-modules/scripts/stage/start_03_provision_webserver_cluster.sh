#!/bin/bash
cd ../../stage/services/webserver-cluster

terraform init

terraform apply -auto-approve
