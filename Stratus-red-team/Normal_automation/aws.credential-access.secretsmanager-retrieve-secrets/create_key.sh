#!/bin/bash

# 사용자 계정 범위 설정
START=1
END=20

# 비밀 저장 경로 설정
SECRET_NAME_PREFIX="MyTestSecret"

# AWS Secrets Manager와 IAM 정책 설정
REGION="us-east-1"
SECRET_VALUE="ThisIsASecretValue"

# 모든 계정에 대해 비밀 생성 및 권한 부여
for i in $(seq $START $END); do
    ACCOUNT="normal-user-$i"
    SECRET_NAME="${SECRET_NAME_PREFIX}-${ACCOUNT}"
    POLICY_NAME="${ACCOUNT}-SecretsManagerPolicy"

    echo "--------------------------------------"
    echo "현재 사용자 계정: $ACCOUNT"

    # AWS CLI 프로파일 설정 확인
    PROFILE_CHECK=$(aws configure list-profiles | grep "$ACCOUNT")
    if [ -z "$PROFILE_CHECK" ]; then
        echo "프로파일이 설정되지 않았습니다: $ACCOUNT. 스킵합니다."
        continue
    fi

    # 인증 확인
    aws sts get-caller-identity --profile $ACCOUNT > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "AWS 인증 실패: $ACCOUNT. 스킵합니다."
        continue
    else
        echo "$ACCOUNT 인증 성공."
    fi

    # 비밀 생성
    echo "비밀 생성 중: $SECRET_NAME"
    aws secretsmanager create-secret \
        --name "$SECRET_NAME" \
        --secret-string "$SECRET_VALUE" \
        --region "$REGION" \
        --profile "$ACCOUNT" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "비밀 생성 실패: $SECRET_NAME. 스킵합니다."
        continue
    else
        echo "비밀 생성 성공: $SECRET_NAME"
    fi

    # IAM 정책 JSON 생성
    POLICY_JSON=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:$REGION:$(aws sts get-caller-identity --profile admin-user --query Account --output text):secret:$SECRET_NAME"
        }
    ]
}
EOF
    )

    # IAM 정책 생성
    echo "IAM 정책 생성 중: $POLICY_NAME"
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$POLICY_JSON" \
        --profile admin-user > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "IAM 정책 생성 실패: $POLICY_NAME. 이미 존재하는 정책일 수 있습니다."
    else
        echo "IAM 정책 생성 성공: $POLICY_NAME"
    fi

    # IAM 정책을 사용자에게 연결
    echo "IAM 정책을 사용자에게 연결 중: $ACCOUNT"
    aws iam attach-user-policy \
        --user-name "$ACCOUNT" \
        --policy-arn "arn:aws:iam::$(aws sts get-caller-identity --profile admin-user --query Account --output text):policy/$POLICY_NAME" \
        --profile admin-user

    if [ $? -ne 0 ]; then
        echo "IAM 정책 연결 실패: $POLICY_NAME -> $ACCOUNT"
    else
        echo "IAM 정책 연결 성공: $POLICY_NAME -> $ACCOUNT"
    fi

    echo "--------------------------------------"
done

echo "모든 사용자 계정에 대한 작업이 완료되었습니다."