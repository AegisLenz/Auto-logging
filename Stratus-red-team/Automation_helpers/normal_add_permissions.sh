#!/bin/bash

# 사용자 계정 이름의 기본 패턴 설정 (normal-user-1 ~ normal-user-20)
USER_PREFIX="normal-user"
START_INDEX=1
END_INDEX=20

# 부여할 정책 ARN 설정
# AWS 정책 이름에 언더스코어(_)가 포함된 정책이 맞는지 확인 후 수정
CLOUDTRAIL_POLICY_ARN="arn:aws:iam::aws:policy/AWSCloudTrail_ReadOnlyAccess"  # 정책 이름 수정
EC2_POLICY_ARN="arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"

# 모든 사용자에게 권한 추가하기
for i in $(seq $START_INDEX $END_INDEX)
do
    USER_NAME="$USER_PREFIX-$i"
    echo "사용자: $USER_NAME 에게 권한 추가 중..."

    # CloudTrail ReadOnlyAccess 정책 추가
    aws iam attach-user-policy --policy-arn $CLOUDTRAIL_POLICY_ARN --user-name $USER_NAME
    if [ $? -eq 0 ]; then
        echo "CloudTrail ReadOnlyAccess 정책이 $USER_NAME 에게 추가되었습니다."
    else
        echo "$USER_NAME 에 CloudTrail 권한 추가 실패."
    fi

    # EC2 ReadOnlyAccess 정책 추가
    aws iam attach-user-policy --policy-arn $EC2_POLICY_ARN --user-name $USER_NAME
    if [ $? -eq 0 ]; then
        echo "EC2 ReadOnlyAccess 정책이 $USER_NAME 에게 추가되었습니다."
    else
        echo "$USER_NAME 에 EC2 권한 추가 실패."
    fi
    echo "---------------------------"
done

echo "모든 사용자에게 권한 추가 완료."
