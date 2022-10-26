#!/bin/bash

SERVICE_PREFIX=s3ich4n-chapter03-ex03

echo $SERVICE_PREFIX-t101study-tfstate

while true; do aws s3 ls s3://$SERVICE_PREFIX-101study-tfstate --recursive --human-readable --summarize ; echo "------------------------------"; date; sleep 1; done
