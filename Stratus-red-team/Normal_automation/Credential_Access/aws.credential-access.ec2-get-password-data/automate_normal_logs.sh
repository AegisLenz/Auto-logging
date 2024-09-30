#!/bin/bash

# 사용자 정보 입력
read -p "사용자 계정 이름을 입력하세요 (예: normal-user-1): " ACCOUNT
read -p "AWS Access Key를 입력하세요: " ACCESS_KEY
read -s -p "AWS Secret Key를 입력하세요: " SECRET_KEY
echo # Secret Key 입력 후 줄바꿈

# 로그 저장 경로 설정
SCENARIO="aws.credential-access.ec2-get-password-data"  # 시나리오 이름 고정
BASE_DIR="/Users/taeyangkim/Desktop/Coding/BoB/Project/AWS" # 올바른 프로젝트 디렉토리 설정
LOG_DIR="$BASE_DIR/scenarios/Credential_Access/$SCENARIO/Normal_logs"
mkdir -p "$LOG_DIR"

# 시간 범위 설정 (2시간 전부터 현재까지)
START_TIME=$(date -u -v -2H +"%Y-%m-%dT%H:%M:%SZ")
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "로그 수집 시작 시간: $START_TIME"
echo "로그 수집 종료 시간: $END_TIME"

# AWS CLI 프로파일 설정
aws configure set aws_access_key_id $ACCESS_KEY --profile $ACCOUNT
aws configure set aws_secret_access_key $SECRET_KEY --profile $ACCOUNT
aws configure set region us-east-1 --profile $ACCOUNT

# AWS 인증 확인
aws sts get-caller-identity --profile $ACCOUNT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "AWS 인증 실패: $ACCOUNT. 스킵합니다."
    exit 1
else
    echo "$ACCOUNT 인증 성공."
fi

# CloudTrail 설정 확인
cloudtrail_status=$(aws cloudtrail describe-trails --profile $ACCOUNT --region us-east-1)
if [[ $cloudtrail_status == *"No trails found"* ]]; then
    echo "CloudTrail이 활성화되지 않았습니다: $ACCOUNT. 스킵합니다."
    exit 1
else
    echo "CloudTrail이 활성화되어 있습니다."
fi

# EC2 인스턴스 존재 여부 확인
instance_check=$(aws ec2 describe-instances --profile $ACCOUNT --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
if [ -z "$instance_check" ]; then
    echo "해당 계정에 EC2 인스턴스가 존재하지 않습니다: $ACCOUNT. 스킵합니다."
    exit 1
else
    echo "EC2 인스턴스가 존재합니다."
fi

# EC2 인스턴스 상태 확인
INSTANCE_ID=$(echo $instance_check | awk '{print $1}')
instance_state=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].State.Name' --output text --profile $ACCOUNT --region us-east-1)
echo "현재 인스턴스 상태: $instance_state"

# 만약 인스턴스가 terminated 상태라면 새로운 인스턴스 생성
if [ "$instance_state" == "terminated" ]; then
    echo "인스턴스가 terminated 상태입니다. 새로운 인스턴스를 생성합니다."
    NEW_INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0230bd60aa48260c6 --count 1 --instance-type t2.micro --key-name MyNewKeyPair --security-group-ids sg-0cf9f8be0200a3404 --subnet-id subnet-0dda00e173ab99f54 --profile $ACCOUNT --region us-east-1 --query 'Instances[0].InstanceId' --output text)
    echo "새로운 인스턴스 생성됨: $NEW_INSTANCE_ID"
    
    # 인스턴스 상태가 running이 될 때까지 대기
    echo "새 인스턴스의 상태를 대기 중..."
    aws ec2 wait instance-running --instance-ids $NEW_INSTANCE_ID --profile $ACCOUNT --region us-east-1
    echo "새 인스턴스가 실행 중입니다."
    INSTANCE_ID=$NEW_INSTANCE_ID
fi

# CloudTrail 정상 로그 수집
echo "CloudTrail 정상 로그 수집"
NORMAL_LOG_FILE="$LOG_DIR/${ACCOUNT}_normal_log.json"
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

echo "정상 로그 수집 완료"