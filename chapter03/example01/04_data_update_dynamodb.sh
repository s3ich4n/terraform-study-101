#!/bin/bash

# DynamoDB API
aws dynamodb get-item --consistent-read \
    --table-name Music \
    --key '{ "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "Happy Day"}}' | jq

# PartiQL for DynamoDB
aws dynamodb execute-statement --statement "SELECT * FROM Music   \
                                            WHERE Artist='Acme Band' AND SongTitle='Happy Day'" | jq

aws dynamodb execute-statement --statement "SELECT * FROM Music   \
                                            WHERE Artist='Acme Band' AND SongTitle='Happy Day'" --output table

aws dynamodb execute-statement --statement "SELECT * FROM Music" --output table
aws dynamodb execute-statement --statement "SELECT * FROM Music" --output text
