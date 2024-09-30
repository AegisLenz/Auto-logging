#!/bin/bash

# 사용자 정보 입력
read -p "사용자 계정 이름을 입력하세요 (예: normal-user-1): " ACCOUNT
read -p "AWS Access Key를 입력하세요: " ACCESS_KEY
read -s -p "AWS Secret Key를 입력하세요: " SECRET_KEY
echo # Secret Key 입력 후 줄바꿈

# AWS CLI 프로파일 구성
aws configure set aws_access_key_id $ACCESS_KEY --profile $ACCOUNT
aws configure set aws_secret_access_key $SECRET_KEY --profile $ACCOUNT
aws configure set region us-east-1 --profile $ACCOUNT

# 파라미터 이름 및 값 설정
PARAMETER_NAME="MySecureParameter-$ACCOUNT"
PARAMETER_VALUE="ThisIsASecureValueFor$ACCOUNT"

# SSM Parameter Store에 SecureString 파라미터 생성
echo "SecureString 파라미터 생성 시도: $PARAMETER_NAME"
aws ssm put-parameter \
    --name $PARAMETER_NAME \
    --value $PARAMETER_VALUE \
    --type SecureString \
    --profile $ACCOUNT \
    --region us-east-1 \
    --overwrite > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "$ACCOUNT SecureString 파라미터 생성 성공."
else
    echo "$ACCOUNT SecureString 파라미터 생성 실패 또는 이미 존재."
fi

# 다양한 SecureString 파라미터 조회 명령어 수행
echo "SecureString 파라미터 조회 명령어 테스트 시작..."

# 1. 파라미터 값 조회 (get-parameter)
echo "1. get-parameter"
aws ssm get-parameter \
    --name $PARAMETER_NAME \
    --with-decryption \
    --profile $ACCOUNT \
    --region us-east-1 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "$ACCOUNT get-parameter 성공."
else
    echo "$ACCOUNT get-parameter 실패."
fi

# 2. 파라미터 메타데이터 조회 (describe-parameters)
echo "2. describe-parameters"
aws ssm describe-parameters \
    --filters "Key=Name,Values=$PARAMETER_NAME" \
    --profile $ACCOUNT \
    --region us-east-1 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "$ACCOUNT describe-parameters 성공."
else
    echo "$ACCOUNT describe-parameters 실패."
fi

# 3. 파라미터 목록 조회 (describe-parameters) - 필터 없이
echo "3. describe-parameters (필터 없이)"
aws ssm describe-parameters \
    --profile $ACCOUNT \
    --region us-east-1 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "$ACCOUNT describe-parameters (필터 없이) 성공."
else
    echo "$ACCOUNT describe-parameters (필터 없이) 실패."
fi

echo "SecureString 파라미터 조회 명령어 테스트 완료."

# 로그 저장 경로 설정
SCENARIO="aws.credential-access.ssm-retrieve-securestring-parameters"
BASE_DIR="/Users/taeyangkim/Desktop/Coding/BoB/Project/AWS"
LOG_DIR="$BASE_DIR/scenarios/Credential_Access/$SCENARIO/Normal_logs"
mkdir -p "$LOG_DIR"
NORMAL_LOG_FILE="$LOG_DIR/${ACCOUNT}_normal_log.json"

# 시간 범위 설정 (예: 2시간 전부터 현재까지)
START_TIME=$(date -u -v -2H +"%Y-%m-%dT%H:%M:%SZ")
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 시작 시간: $START_TIME"
echo "로그 수집 종료 시간: $END_TIME"

# CloudTrail 정상 로그 수집
echo "CloudTrail 정상 로그 수집"
aws cloudtrail lookup-events \
    --profile $ACCOUNT \
    --region us-east-1 \
    --lookup-attributes AttributeKey=Username,AttributeValue=$ACCOUNT \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output json > "$NORMAL_LOG_FILE"

if [ -s "$NORMAL_LOG_FILE" ]; then
    echo "정상 로그 파일 저장됨: $NORMAL_LOG_FILE"
else
    echo "정상 로그 파일 생성 안됨. CloudTrail 설정 또는 시간 범위를 확인하세요."
fi

echo "모든 작업이 완료되었습니다."