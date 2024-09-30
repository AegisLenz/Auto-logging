#!/bin/bash

# 사용자 입력을 통해 계정 정보 받기
echo "공격자 계정 이름을 입력하세요:"
read ACCOUNT
echo "AWS Access Key를 입력하세요:"
read ACCESS_KEY
echo "AWS Secret Key를 입력하세요:"
read -s SECRET_KEY  # Secret Key는 보이지 않게 입력받기

# 로그 저장 경로 설정
SCENARIO="$1"  # 첫 번째 인자로 시나리오 이름을 입력받음
BASE_DIR="/Users/taeyangkim/Desktop/Coding/Project/AWS" # 올바른 프로젝트 디렉토리 설정
LOG_DIR="$BASE_DIR/scenarios/Credential_Access/$SCENARIO/Attack_logs"
WARMUP_LOG_DIR="$LOG_DIR/Warmup_logs"
DETONATE_LOG_DIR="$LOG_DIR/Detonate_logs"

# 로그 디렉토리 생성
mkdir -p "$WARMUP_LOG_DIR"
mkdir -p "$DETONATE_LOG_DIR"
echo "Warmup 로그 저장 경로: $WARMUP_LOG_DIR"
echo "Detonate 로그 저장 경로: $DETONATE_LOG_DIR"

# macOS와 리눅스의 date 명령어 차이 해결
add_minutes() {
    date -u -v +"$1"M +"%Y-%m-%dT%H:%M:%SZ"
}

# 현재 시간에서 1시간 전
START_TIME=$(date -u -v -60M +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 시작 시간 (1시간 전): $START_TIME"

# 현재 시간에서 3시간 후
END_TIME=$(date -u -v +180M +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 종료 시간 (3시간 후): $END_TIME"

# AWS CLI 프로파일 구성
aws configure set aws_access_key_id $ACCESS_KEY --profile $ACCOUNT
aws configure set aws_secret_access_key $SECRET_KEY --profile $ACCOUNT
aws configure set region us-east-1 --profile $ACCOUNT

# AWS 프로파일 및 리전 설정
export AWS_PROFILE=$ACCOUNT
export AWS_REGION=us-east-1

# 인증 확인
aws sts get-caller-identity --profile $ACCOUNT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "AWS 인증 실패: $ACCOUNT. 스킵합니다."
    exit 1
fi

# Warmup 수행
echo "Warming up for scenario $SCENARIO as $ACCOUNT"
warmup_output=$(stratus warmup $SCENARIO 2>&1)
if [ $? -ne 0 ]; then
    echo "Warmup 실패: $ACCOUNT. 스킵합니다."
    echo "$warmup_output"  # 에러 메시지 출력
    exit 1
fi

# Warmup 로그 수집
WARMUP_LOG_FILE="$WARMUP_LOG_DIR/${ACCOUNT}_warmup_log.json"
echo "CloudTrail Warmup 로그 수집"
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=Username,AttributeValue=$ACCOUNT \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output json > "$WARMUP_LOG_FILE"

if [ -s "$WARMUP_LOG_FILE" ]; then
    echo "Warmup 로그 파일 저장됨: $WARMUP_LOG_FILE"
else
    echo "Warmup 로그 파일 생성 안됨"
fi

# Detonate 수행
echo "Detonating attack scenario $SCENARIO as $ACCOUNT"
detonate_output=$(stratus detonate $SCENARIO 2>&1)
if [ $? -ne 0 ]; then
    echo "Detonation 실패: $ACCOUNT. 스킵합니다."
    echo "$detonate_output"  # 에러 메시지 출력
    exit 1
fi

# Detonate 로그 수집
DETONATE_LOG_FILE="$DETONATE_LOG_DIR/${ACCOUNT}_detonate_log.json"
echo "CloudTrail Detonate 로그 수집"
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=Username,AttributeValue=$ACCOUNT \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output json > "$DETONATE_LOG_FILE"

if [ -s "$DETONATE_LOG_FILE" ]; then
    echo "Detonate 로그 파일 저장됨: $DETONATE_LOG_FILE"
else
    echo "Detonate 로그 파일 생성 안됨"
fi

# Cleanup 수행
echo "Cleaning up resources for $SCENARIO as $ACCOUNT"
stratus cleanup $SCENARIO --force
if [ $? -ne 0 ]; then
    echo "Cleanup 실패: $ACCOUNT."
fi

echo "Completed cleanup for $ACCOUNT"
echo "Warmup 및 Detonate 로그 수집 및 Cleanup 완료"
