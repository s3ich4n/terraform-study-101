#!/bin/bash
cd prod/services/webserver-cluster

ALBDNS=$(terraform output -raw alb_dns)
while true; do curl --connect-timeout 1  http://$ALBDNS ; echo; echo "------------------------------"; date; sleep 1; done
