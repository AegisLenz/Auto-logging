#!/bin/bash

# 정책 배열 설정 (필요에 따라 다른 정책 추가 가능)
POLICIES=("arn:aws:iam::aws:policy/AdministratorAccess")

# 사용자 생성 및 정책 연결 함수
create_user_with_policies() {
  USER_NAME="$1"
  
  # IAM 사용자 생성
  echo "IAM 사용자 $USER_NAME 생성 중..."
  aws iam create-user --user-name $USER_NAME
  
  # 사용자에게 정책 연결
  for POLICY_ARN in "${POLICIES[@]}"; do
    echo "사용자 $USER_NAME에 정책 $POLICY_ARN 연결 중..."
    aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN
  done

  # 사용자의 액세스 키 생성 및 저장
  ACCESS_KEYS=$(aws iam create-access-key --user-name $USER_NAME)

  # 액세스 키와 비밀 액세스 키 추출
  ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
  SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

  # 액세스 키 정보를 출력
  echo "ACCESS_KEY_ID: $ACCESS_KEY_ID"
  echo "SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY"
}

# IAM 사용자 20명 생성
for i in {01..20}; do
  USER_NAME="normal-user-${i}"
  create_user_with_policies "$USER_NAME"
done

echo "모든 정상 로그용 IAM 사용자 생성 완료."
#!/bin/bash

# 로그 파일 설정
LOG_FILE="create_iam_users.log"
touch $LOG_FILE

# 정책 배열 설정 (필요에 따라 다른 정책 추가 가능)
POLICIES=("arn:aws:iam::aws:policy/AdministratorAccess")

# 사용자 생성 및 정책 연결 함수
create_user_with_policies() {
  USER_NAME="$1"
  
  # IAM 사용자 생성
  echo "IAM 사용자 $USER_NAME 생성 중..." | tee -a $LOG_FILE
  aws iam create-user --user-name $USER_NAME 2>&1 | tee -a $LOG_FILE
  
  # 사용자에게 정책 연결
  for POLICY_ARN in "${POLICIES[@]}"; do
    echo "사용자 $USER_NAME에 정책 $POLICY_ARN 연결 중..." | tee -a $LOG_FILE
    aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN 2>&1 | tee -a $LOG_FILE
  done

  # 사용자의 액세스 키 생성 및 저장
  ACCESS_KEYS=$(aws iam create-access-key --user-name $USER_NAME 2>&1 | tee -a $LOG_FILE)

  # 액세스 키와 비밀 액세스 키 추출
  ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
  SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

  # 액세스 키 정보를 출력 및 로그에 저장
  echo "ACCESS_KEY_ID: $ACCESS_KEY_ID" | tee -a $LOG_FILE
  echo "SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY" | tee -a $LOG_FILE
}

# IAM 사용자 20명 생성
for i in {01..20}; do
  USER_NAME="normal-user-${i}"
  create_user_with_policies "$USER_NAME"
  
  # 사용자 생성 후 2초 대기
  sleep 2
done

echo "모든 정상 로그용 IAM 사용자 생성 완료." | tee -a $LOG_FILE
