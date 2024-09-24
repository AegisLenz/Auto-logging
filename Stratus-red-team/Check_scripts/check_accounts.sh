# accounts.sh 스크립트 예시
#!/bin/bash

# 모든 계정의 프로파일 배열
PROFILES=("attack_user" "attack_user_02" "attack_user_03" "attack_user_04" "attack_user_05" "attack_user_06" "attack_user_07" "attack_user_08" "attack_user_09" "attack_user_10")

for profile in "${PROFILES[@]}"; do
    echo "Checking AWS authentication for profile: $profile"
    aws sts get-caller-identity --profile $profile
    if [ $? -eq 0 ]; then
        echo "$profile authentication successful."
    else
        echo "$profile authentication failed."
    fi
    echo "---------------------------"
done
