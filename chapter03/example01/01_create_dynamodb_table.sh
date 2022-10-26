#!/bin/bash
# 테이블 생성
aws dynamodb create-table \
    --table-name Music \
    --attribute-definitions \
        AttributeName=Artist,AttributeType=S \
        AttributeName=SongTitle,AttributeType=S \
    --key-schema \
        AttributeName=Artist,KeyType=HASH \
        AttributeName=SongTitle,KeyType=RANGE \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --table-class STANDARD

# 테이블 생성 확인
aws dynamodb list-tables --output text
TABLENAMES	Music

aws dynamodb describe-table --table-name Music | jq
aws dynamodb describe-table --table-name Music --output table
