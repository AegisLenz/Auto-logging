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
SCENARIO="aws.defense-evasion.cloudtrail-stop-normal"  # 정상 로그 시나리오 이름 고정
BASE_DIR="/Users/taeyangkim/Desktop/Coding/BoB/Project/AWS" # 올바른 프로젝트 디렉토리 설정
LOG_DIR="$BASE_DIR/scenarios/Defense_Evasion/$SCENARIO/Normal_logs"
mkdir -p "$LOG_DIR"

# 시간 범위 설정 (예: 2시간 전부터 현재까지)
START_TIME=$(date -u -v -2H +"%Y-%m-%dT%H:%M:%SZ")
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

# CloudTrail 이름 설정
TRAIL_NAME="MyTestTrail"

# CloudTrail 상태 조회
echo "CloudTrail 상태 조회: $TRAIL_NAME"
aws cloudtrail get-trail-status --name $TRAIL_NAME --profile $ACCOUNT --region us-east-1

# CloudTrail 설정 조회
echo "CloudTrail 설정 조회: $TRAIL_NAME"
aws cloudtrail describe-trails --trail-name-list $TRAIL_NAME --profile $ACCOUNT --region us-east-1

# CloudTrail 이벤트 선택기 조회
echo "CloudTrail 이벤트 선택기 조회: $TRAIL_NAME"
aws cloudtrail get-event-selectors --trail-name $TRAIL_NAME --profile $ACCOUNT --region us-east-1

# CloudTrail 이벤트 조회 (예: 지난 2시간 동안의 이벤트)
echo "CloudTrail 이벤트 조회: $TRAIL_NAME"
aws cloudtrail lookup-events \
    --profile $ACCOUNT \
    --region us-east-1 \
    --lookup-attributes AttributeKey=Username,AttributeValue=$ACCOUNT \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output json > "$LOG_DIR/${ACCOUNT}_normal_log.json"

# 결과 확인
if [ -s "$LOG_DIR/${ACCOUNT}_normal_log.json" ]; then
    echo "정상 로그 파일 저장됨: $LOG_DIR/${ACCOUNT}_normal_log.json"
else
    echo "정상 로그 파일 생성 안됨. CloudTrail 설정 또는 시간 범위를 확인하세요."
fi

echo "정상 로그 수집 완료"