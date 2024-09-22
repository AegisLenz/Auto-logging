import subprocess

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# IAM 역할에 정책 첨부 함수
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

# 메인 실행 부분
if __name__ == "__main__":
    with open("role_name.txt", "r") as f:
        role_name = f.read().strip()

    with open("policy_arn.txt", "r") as f:
        policy_arn = f.read().strip()

    attach_role_policy(role_name, policy_arn)