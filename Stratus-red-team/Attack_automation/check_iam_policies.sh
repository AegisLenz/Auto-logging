# check_iam_policies.sh 스크립트 예시
#!/bin/bash

# 계정별 프로파일 배열
PROFILES=("attack_user" "attack_user_02" "attack_user_03" "attack_user_04" "attack_user_05" "attack_user_06" "attack_user_07" "attack_user_08" "attack_user_09" "attack_user_10")

for profile in "${PROFILES[@]}"; do
    echo "Checking IAM policies for profile: $profile"
    aws iam list-attached-user-policies --user-name $profile --profile $profile
    echo "---------------------------"
done
