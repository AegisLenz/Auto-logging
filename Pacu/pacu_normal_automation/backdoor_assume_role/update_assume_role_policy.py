import subprocess
import json

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# AssumeRole 정책 업데이트 함수
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

# 메인 실행 부분
if __name__ == "__main__":
    with open("role_name.txt", "r") as f:
        role_name = f.read().strip()

    with open("user_name.txt", "r") as f:
        user_name = f.read().strip()

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

    update_assume_role_policy(role_name, assume_role_policy)