#!/bin/bash
while true; do curl --connect-timeout 1  http://$PIP:$PPT/ ; echo "------------------------------"; date; sleep 1; done
