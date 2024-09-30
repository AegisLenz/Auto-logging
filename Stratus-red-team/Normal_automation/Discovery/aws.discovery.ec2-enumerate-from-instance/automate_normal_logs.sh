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

# 로그 저장 경로 설정
SCENARIO="aws.discovery.ec2-enumerate-from-instance-normal"  # 정상 로그 시나리오 이름
LOG_DIR="./Normal_logs
" # 로그 파일 저장 경로
mkdir -p "$LOG_DIR"

# 시간 범위 설정 (예: 1시간 전부터 현재까지)
START_TIME=$(date -u -v -1H +"%Y-%m-%dT%H:%M:%SZ")
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 시작 시간: $START_TIME"
echo "로그 수집 종료 시간: $END_TIME"

# AWS CLI 프로파일 설정 확인
PROFILE_CHECK=$(aws configure list-profiles | grep "$ACCOUNT")
if [ -z "$PROFILE_CHECK" ]; then
    echo "프로파일이 설정되지 않았습니다: $ACCOUNT. 스킵합니다."
    exit 1
fi

# 인증 확인
aws sts get-caller-identity --profile $ACCOUNT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "AWS 인증 실패: $ACCOUNT. 스킵합니다."
    exit 1
else
    echo "$ACCOUNT 인증 성공."
fi

# CloudTrail 이벤트 조회 및 JSON 파일 저장
echo "CloudTrail 이벤트 조회 및 저장 중..."
aws cloudtrail lookup-events \
    --profile $ACCOUNT \
    --region us-east-1 \
    --lookup-attributes AttributeKey=EventSource,AttributeValue=ec2.amazonaws.com \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output json > "$LOG_DIR/${ACCOUNT}_ec2_cloudtrail_events.json"

# 결과 확인
if [ -s "$LOG_DIR/${ACCOUNT}_ec2_cloudtrail_events.json" ]; then
    echo "JSON 로그 파일 저장됨: $LOG_DIR/${ACCOUNT}_ec2_cloudtrail_events.json"
else
    echo "JSON 로그 파일 생성 안됨. CloudTrail 설정 또는 시간 범위를 확인하세요."
fi

echo "CloudTrail 이벤트 JSON 로그 수집 완료"