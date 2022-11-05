#!/bin/bash

NICKNAME=s3ich4n-ch03-isolation
while true; do aws s3 ls s3://$NICKNAME-t101study-tfstate-week3 --recursive --human-readable --summarize ; echo "------------------------------"; date; sleep 1; done
