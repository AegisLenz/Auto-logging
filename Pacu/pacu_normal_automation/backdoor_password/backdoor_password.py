import subprocess
import json
import time
import uuid
import random
import string

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# 랜덤 사용자 이름 생성
def generate_random_name(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"

# 랜덤 비밀번호 생성 함수
def generate_random_password(length=16):
    characters = string.ascii_letters + string.digits + "!@#$%^&*()"
    password = ''.join(random.choice(characters) for i in range(length))
    return password

# IAM 사용자 생성 함수
def create_iam_user(user_name):
    command = [
        "aws", "iam", "create-user",
        "--user-name", user_name
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"IAM User {user_name} created successfully.")
        print(response)

# IAM 사용자 비밀번호 설정 함수
def set_iam_user_password(user_name, password):
    command = [
        "aws", "iam", "create-login-profile",
        "--user-name", user_name,
        "--password", password,
        "--password-reset-required"
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"Password set for {user_name} successfully.")
        print(response)

# 메인 실행 부분
if __name__ == "__main__":
    # 1. 사용자 이름 생성
    user_name = generate_random_name("user")

    # 2. IAM 사용자 생성
    create_iam_user(user_name)

    # 10초 대기 (반영 대기)
    time.sleep(10)

    # 3. 랜덤 비밀번호 생성 (16자리)
    user_password = generate_random_password(16)

    # 4. 사용자 비밀번호 설정
    set_iam_user_password(user_name, user_password)

    # 10초 대기 (반영 대기)
    time.sleep(10)

    print(f"Generated password for {user_name}: {user_password}")