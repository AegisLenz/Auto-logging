import subprocess
import json
import uuid
import time

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# IAM 사용자 생성
def create_iam_user(user_name):
    command = [
        "aws", "iam", "create-user",
        "--user-name", user_name
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"IAM User {user_name} created successfully.")
        print(response)

# IAM 역할 생성 (AssumeRole 정책)
def create_iam_role(role_name, assume_role_policy):
    command = [
        "aws", "iam", "create-role",
        "--role-name", role_name,
        "--assume-role-policy-document", json.dumps(assume_role_policy)
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"IAM Role {role_name} created successfully.")
        print(response)

# IAM 정책 생성
def create_iam_policy(policy_name, policy_document):
    command = [
        "aws", "iam", "create-policy",
        "--policy-name", policy_name,
        "--policy-document", json.dumps(policy_document)
    ]
    response = run_aws_cli_command(command)
    if response:
        policy_arn = json.loads(response)["Policy"]["Arn"]
        print(f"IAM Policy {policy_name} created successfully.")
        print(response)
        return policy_arn
    return None

# IAM 역할에 정책 첨부
def attach_role_policy(role_name, policy_arn):
    command = [
        "aws", "iam", "attach-role-policy",
        "--role-name", role_name,
        "--policy-arn", policy_arn
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"Policy {policy_arn} attached to role {role_name} successfully.")
        print(response)

# AssumeRole 정책 설정 함수
def update_assume_role_policy(role_name, assume_role_policy):
    command = [
        "aws", "iam", "update-assume-role-policy",
        "--role-name", role_name,
        "--policy-document", json.dumps(assume_role_policy)
    ]
    response = run_aws_cli_command(command)
    if response:
        print(f"AssumeRole policy updated for role {role_name} successfully.")
        print(response)

# 랜덤한 이름을 생성하는 함수 (UUID 사용)
def generate_random_name(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"  # 8자리 랜덤 이름 생성

# AssumeRole 정책 정의
assume_role_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::891377205497:user/new_user"  # AWS 계정 ID를 사용
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

# 사용자에게 적용할 정책 정의 (예: S3 접근 정책)
policy_document = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": "*"
        }
    ]
}

# 파이썬 코드 실행 (IAM 사용자 및 역할 생성)
user_name = generate_random_name("user")  # 사용자 이름을 랜덤으로 생성
role_name = generate_random_name("role")  # 역할 이름을 랜덤으로 생성
policy_name = generate_random_name("policy")  # 정책 이름을 랜덤으로 생성

# 1. 랜덤 사용자 생성
create_iam_user(user_name)

# 10초 대기 시간 추가
time.sleep(10)

# 2. AssumeRole 정책에서 Principal에 사용자 이름을 반영
assume_role_policy["Statement"][0]["Principal"]["AWS"] = f"arn:aws:iam::891377205497:user/{user_name}"

# 3. 역할 생성
create_iam_role(role_name, assume_role_policy)

# 10초 대기 시간 추가
time.sleep(10)

# 4. 정책 생성
policy_arn = create_iam_policy(policy_name, policy_document)

# 10초 대기 시간 추가
time.sleep(10)

# 5. 역할에 정책 첨부
if policy_arn:
    attach_role_policy(role_name, policy_arn)

# 10초 대기 시간 추가
time.sleep(10)

# 6. AssumeRole 정책 업데이트 (만약 수정이 필요한 경우)
update_assume_role_policy(role_name, assume_role_policy)