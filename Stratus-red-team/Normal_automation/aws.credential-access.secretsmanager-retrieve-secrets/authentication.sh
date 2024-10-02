#!/bin/bash

# 설정
ADMIN_PROFILE="admin-user"  # 관리자로 사용할 프로필
SECRET_NAME="MyTestSecret"  # 생성할 비밀의 이름
SECRET_STRING="ThisIsASecretValue"  # 비밀의 내용
REGION="us-east-1"  # 사용할 리전
SECRET_POLICY_FILE="secret-policy.json"  # 비밀 정책 파일

# 비밀 생성
echo "비밀 생성 중..."
aws secretsmanager create-secret \
    --name $SECRET_NAME \
    --secret-string $SECRET_STRING \
    --region $REGION \
    --profile $ADMIN_PROFILE > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "비밀 생성 실패 또는 이미 존재합니다. 기존 비밀을 사용합니다."
else
    echo "비밀 생성 완료: $SECRET_NAME"
fi

# 비밀 정책 템플릿 작성
cat <<EOF > $SECRET_POLICY_FILE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# 사용자 범위 설정
START=1
END=20

# 각 사용자에 대해 비밀 접근 권한 부여
for i in $(seq $START $END); do
    USERNAME="normal-user-$i"

    echo "--------------------------------------"
    echo "현재 사용자 계정: $USERNAME"

    # 각 사용자에 대해 비밀 접근 권한 부여
    aws iam put-user-policy \
        --user-name $USERNAME \
        --policy-name "${USERNAME}-SecretsManagerPolicy" \
        --policy-document file://$SECRET_POLICY_FILE \
        --profile $ADMIN_PROFILE

    if [ $? -eq 0 ]; then
        echo "$USERNAME에게 비밀 접근 권한 부여 완료."
    else
        echo "$USERNAME에게 비밀 접근 권한 부여 실패."
    fi

    echo "--------------------------------------"
done

echo "모든 사용자에 대한 비밀 접근 권한 부여 완료."