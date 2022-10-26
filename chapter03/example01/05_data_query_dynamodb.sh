#!/bin/bash

# PartiQL for DynamoDB
aws dynamodb execute-statement --statement "SELECT * FROM Music   \
                                            WHERE Artist='Acme Band'" | jq
