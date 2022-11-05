#!/bin/bash

aws s3 rm s3://s3ich4n-ex3-file-layout-bucket --recursive

aws s3api delete-objects \
    --bucket s3ich4n-ex3-file-layout-bucket \
    --delete "$(aws s3api list-object-versions \
    --bucket "s3ich4n-ex3-file-layout-bucket" \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-objects --bucket s3ich4n-ex3-file-layout-bucket \
    --delete "$(aws s3api list-object-versions --bucket "s3ich4n-ex3-file-layout-bucket" \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

terraform destroy -auto-approve
