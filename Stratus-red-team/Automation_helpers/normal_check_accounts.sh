#!/bin/bash

# 모든 계정의 프로파일 배열 (normal_user-01 ~ normal_user-20)
PROFILES=()
for i in $(seq -f "normal-user-%02g" 1 20); do
    PROFILES+=("$i")
done

for profile in "${PROFILES[@]}"; do
    echo "Checking AWS authentication for profile: $profile"
    
    # 환경 변수로 프로파일과 지역 설정
    export AWS_PROFILE=$profile
    export AWS_DEFAULT_REGION=us-east-1
    
    # 인증 확인
    aws sts get-caller-identity
    if [ $? -eq 0 ]; then
        echo "$profile authentication successful."
    else
        echo "$profile authentication failed."
    fi
    echo "---------------------------"
    
    # 환경 변수 해제
    unset AWS_PROFILE
    unset AWS_DEFAULT_REGION
done
