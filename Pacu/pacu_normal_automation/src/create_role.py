import subprocess
import json
import uuid

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# 랜덤한 역할 이름 생성
def generate_random_name(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"

# IAM 역할 생성 함수
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

# 메인 실행 부분
if __name__ == "__main__":
    with open("user_name.txt", "r") as f:
        user_name = f.read().strip()

    role_name = generate_random_name("role")

    # AssumeRole 정책 정의
    assume_role_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": f"arn:aws:iam::891377205497:user/{user_name}"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }

    create_iam_role(role_name, assume_role_policy)

    # 역할 이름을 파일에 저장하여 다음 단계에서 사용
    with open("role_name.txt", "w") as f:
        f.write(role_name)