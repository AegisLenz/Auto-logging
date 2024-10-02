#!/bin/bash

# 사용자 계정 범위 설정
START=1
END=20

# 이미지 ID, 보안 그룹 ID, 서브넷 ID 등 공통 변수 설정
AMI_ID="ami-0230bd60aa48260c6"
INSTANCE_TYPE="t2.micro"
KEY_NAME="MyNewKeyPair"  # 기존의 MyKeyPair에서 MyNewKeyPair로 변경
SECURITY_GROUP_ID="sg-0cf9f8be0200a3404"
SUBNET_ID="subnet-0dda00e173ab99f54"
REGION="us-east-1"

# 계정별로 EC2 인스턴스 생성
for i in $(seq -f "%g" $START $END); do
    ACCOUNT="normal-user-$i"
    echo "현재 사용자 계정: $ACCOUNT"

    # EC2 인스턴스 생성
    echo "EC2 인스턴스 생성 중: $ACCOUNT"
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-group-ids $SECURITY_GROUP_ID \
        --subnet-id $SUBNET_ID \
        --region $REGION \
        --profile $ACCOUNT \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ $? -eq 0 ]; then
        echo "생성된 인스턴스 ID: $INSTANCE_ID"
    else
        echo "인스턴스 생성 실패: $ACCOUNT"
    fi

    echo "--------------------------------------"
done

echo "모든 사용자 계정에 대한 EC2 인스턴스 생성이 완료되었습니다."