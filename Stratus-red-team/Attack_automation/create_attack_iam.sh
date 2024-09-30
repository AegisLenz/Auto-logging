#!/bin/bash

# 사용자 이름을 명령줄 인수로 받음
if [ -z "$1" ]; then
  echo "사용자 이름을 입력하세요."
  echo "사용법: $0 <사용자이름>"
  exit 1
fi

USER_NAME="$1"

# 정책 배열을 명령줄 인수로 전달받거나 기본값 설정
POLICIES=("arn:aws:iam::aws:policy/AdministratorAccess")

# IAM 사용자 생성
echo "IAM 사용자 $USER_NAME 생성 중..."
aws iam create-user --user-name $USER_NAME

# 사용자에게 관리자 권한 또는 지정된 정책 연결
for POLICY_ARN in "${POLICIES[@]}"; do
  echo "사용자 $USER_NAME에 정책 $POLICY_ARN 연결 중..."
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN
done

# 사용자의 액세스 키 생성 및 저장
ACCESS_KEYS=$(aws iam create-access-key --user-name $USER_NAME)

# 액세스 키와 비밀 액세스 키 추출
ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

# 액세스 키 정보를 출력하여 aws configure에서 사용
echo "ACCESS_KEY_ID: $ACCESS_KEY_ID"
echo "SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY"