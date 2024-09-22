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

# 랜덤한 정책 이름 생성
def generate_random_name(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"

# IAM 정책 생성 함수
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

# 메인 실행 부분
if __name__ == "__main__":
    policy_name = generate_random_name("policy")

    # 정책 정의 (S3 접근 정책 예시)
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

    policy_arn = create_iam_policy(policy_name, policy_document)

    # 정책 ARN을 파일에 저장하여 다음 단계에서 사용
    with open("policy_arn.txt", "w") as f:
        f.write(policy_arn)