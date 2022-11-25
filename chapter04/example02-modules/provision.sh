#!/bin/bash

echo '[PRODUCTION] This command will CREATE ALL EXAMPLES. '
printf 'THESE COMMANDS WILL CHARGE pay-as-you-go. continue? (y/n)? '
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.

    cd scripts/prod

    echo ""
    echo "################################"
    echo "phase 1) create S3 bucket"
    echo "################################"
    echo ""

    ./start_01_provision_s3.sh

    echo ""
    echo "################################"
    echo "phase 2) create RDS"
    echo "################################"
    echo ""

    ./start_02_provision_rds.sh

    echo ""
    echo "################################"
    echo "phase 3) create ASG EC2 w/ ALB"
    echo "################################"
    echo ""

    ./start_03_provision_webserver_cluster.sh

    echo ""
    echo "################################"
    echo "DONE"
    echo "################################"
    echo ""

else

    echo No

fi
