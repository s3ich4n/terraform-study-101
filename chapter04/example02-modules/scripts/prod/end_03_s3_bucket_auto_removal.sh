#!/bin/bash

cd ../../global/s3

aws s3 rm s3://ex4-s3-bucket --recursive

aws s3api delete-objects \
    --bucket ex4-s3-bucket \
    --delete "$(aws s3api list-object-versions \
    --bucket "ex4-s3-bucket" \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-objects --bucket ex4-s3-bucket \
    --delete "$(aws s3api list-object-versions --bucket "ex4-s3-bucket" \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

terraform destroy -auto-approve
