#!/bin/bash

# 정상 계정 정보 파일 경로 설정 (절대 경로로 수정)
USER_CSV="/Users/taeyangkim/Desktop/normal_users.csv"

# CSV 파일이 존재하는지 확인
if [ ! -f "$USER_CSV" ]; then
    echo "CSV 파일을 찾을 수 없습니다: $USER_CSV"
    exit 1
fi

# CSV 파일을 읽어서 각 사용자 프로파일 등록
while IFS=, read -r UserName AccessKeyId SecretAccessKey
do
    # 헤더 라인은 무시
    if [ "$UserName" == "UserName" ]; then
        continue
    fi

    # AWS CLI 프로파일 설정
    echo "프로파일 설정 중: $UserName"
    aws configure set aws_access_key_id $AccessKeyId --profile $UserName
    aws configure set aws_secret_access_key $SecretAccessKey --profile $UserName
    aws configure set region us-east-1 --profile $UserName

    # 설정 확인
    echo "AWS CLI 프로파일이 설정되었습니다: $UserName"

done < "$USER_CSV"

echo "모든 정상 계정에 대한 AWS CLI 프로파일 등록이 완료되었습니다."
