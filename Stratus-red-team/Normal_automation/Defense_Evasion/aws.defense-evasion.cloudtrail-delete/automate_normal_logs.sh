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
SCENARIO="aws.defense-evasion.cloudtrail-delete"  # 시나리오 이름 고정
BASE_DIR="/Users/taeyangkim/Desktop/Coding/BoB/Project/AWS" # 올바른 프로젝트 디렉토리 설정
LOG_DIR="$BASE_DIR/scenarios/Defense_Evasion/$SCENARIO/Normal_logs"
mkdir -p "$LOG_DIR"
NORMAL_LOG_FILE="$LOG_DIR/${ACCOUNT}_normal_log.json"

# 시간 범위 설정 (예: 2시간 전부터 현재까지)
START_TIME=$(date -u -v -2H +"%Y-%m-%dT%H:%M:%SZ")
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 시작 시간: $START_TIME"
echo "로그 수집 종료 시간: $END_TIME"

# CloudTrail 설정 확인
echo "CloudTrail 설정 확인"
trail_check=$(aws cloudtrail describe-trails --profile $ACCOUNT --region us-east-1)
if [[ -z "$trail_check" || "$trail_check" == *"No trails found"* ]]; then
    echo "$ACCOUNT CloudTrail 설정 없음. CloudTrail 설정 후 다시 시도하세요."
    exit 1
else
    echo "$ACCOUNT CloudTrail 설정 확인됨."
fi

# CloudTrail 이벤트 기록 확인 (정상적인 액션 수행)
TRAIL_NAME=$(aws cloudtrail describe-trails --query 'trailList[0].Name' --output text --profile $ACCOUNT --region us-east-1)

# CloudTrail에서 특정 로그를 삭제하려는 시도 (하지만 성공하지 않아야 함)
echo "CloudTrail 로그 파일 위치 확인"
S3_BUCKET=$(aws cloudtrail describe-trails --query 'trailList[0].S3BucketName' --output text --profile $ACCOUNT --region us-east-1)

if [ -z "$S3_BUCKET" ]; then
    echo "$ACCOUNT: CloudTrail에 대한 S3 버킷 설정이 없습니다. 스킵합니다."
else
    echo "CloudTrail 로그 파일이 저장되는 S3 버킷: $S3_BUCKET"

    # S3에서 CloudTrail 로그 파일 목록 조회 (정상적인 파일 조회 시도)
    echo "S3 버킷에서 CloudTrail 로그 파일 조회"
    aws s3 ls s3://$S3_BUCKET --profile $ACCOUNT --region us-east-1 > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "CloudTrail 로그 파일 조회 성공 (정상적인 시도)."
    else
        echo "CloudTrail 로그 파일 조회 실패."
    fi

    # CloudTrail 로그 파일 삭제 시도 (정상 로그에서는 실제 삭제하지 않음)
    echo "CloudTrail 로그 파일 삭제 시도 (정상적으로 수행되지 않아야 함)"
    # 실제로 삭제 명령은 주석 처리하여 실행되지 않도록 함
    # aws s3 rm s3://$S3_BUCKET/<로그파일경로> --profile $ACCOUNT --region us-east-1
    echo "CloudTrail 로그 파일 삭제 시도 (실제로 수행되지 않음)."
fi

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