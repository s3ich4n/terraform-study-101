#!/bin/bash

aws s3 rm s3://ex8-s3-bucket --recursive

aws s3api delete-objects \
    --bucket ex8-s3-bucket \
    --delete "$(aws s3api list-object-versions \
    --bucket "ex8-s3-bucket" \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-objects --bucket ex8-s3-bucket \
    --delete "$(aws s3api list-object-versions --bucket "ex8-s3-bucket" \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

terraform destroy -auto-approve
