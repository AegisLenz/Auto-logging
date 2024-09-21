import subprocess
import uuid

# AWS CLI 명령어 실행 함수
def run_aws_cli_command(command):
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    else:
        print(f"Error: {result.stderr}")
        return None

# 랜덤한 사용자 이름 생성
def generate_random_name(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"

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

# 메인 실행 부분
if __name__ == "__main__":
    user_name = generate_random_name("user")
    create_iam_user(user_name)
    # 사용자 이름을 파일에 저장하여 다음 단계에서 사용
    with open("user_name.txt", "w") as f:
        f.write(user_name)