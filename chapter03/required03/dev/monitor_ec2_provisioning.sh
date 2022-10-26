#!/bin/bash

# 출력된 EC2 퍼블릭IP로 cul 접속 확인
MYIP=$(terraform output -raw myec2_public_ip)
while true; do curl --connect-timeout 1  http://$MYIP/ ; echo "------------------------------"; date; sleep 1; done
