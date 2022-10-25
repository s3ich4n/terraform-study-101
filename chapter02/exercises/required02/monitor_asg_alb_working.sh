#!/bin/bash

ALBDNS=$(terraform output -raw s3ich4n-chapter02-ex02-alb_dns)
for i in {1..100}; do curl -s http://$ALBDNS/ ; done | sort | uniq -c | sort -nr
