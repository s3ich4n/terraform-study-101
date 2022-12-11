#!/bin/bash

printf '[STAGING] These commands will DESTROY ALL EXAMPLES. continue? (y/n)? '
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.

    cd scripts/stage

    echo ""
    echo "################################"
    echo "phase 1) destroy ASG EC2 w/ ALB"
    echo "################################"
    echo ""

    ./end_01_webserver_cluster.sh

    echo ""
    echo "################################"
    echo "phase 2) destroy RDS"
    echo "################################"
    echo ""

    ./end_02_rds.sh

    echo ""
    echo "################################"
    echo "phase 3) destroy S3 bucket"
    echo "################################"
    echo ""

    ./end_03_s3_bucket_auto_removal.sh

    echo ""
    echo "################################"
    echo "DONE"
    echo "################################"
    echo ""

else

    echo No

fi
