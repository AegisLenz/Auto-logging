import subprocess
import json

# 역할에 첨부된 관리형 정책 분리 함수
def detach_managed_policies(role_name):
    # 역할에 첨부된 정책 목록 가져오기
    result = subprocess.run([
        "aws", "iam", "list-attached-role-policies",
        "--role-name", role_name
    ], capture_output=True, text=True)

    if result.returncode == 0:
        policies = json.loads(result.stdout)
        for policy in policies['AttachedPolicies']:
            # 각 정책 분리
            policy_arn = policy['PolicyArn']
            detach_result = subprocess.run([
                "aws", "iam", "detach-role-policy",
                "--role-name", role_name,
                "--policy-arn", policy_arn
            ], capture_output=True, text=True)

            if detach_result.returncode == 0:
                print(f"Detached policy: {policy_arn}")
            else:
                print(f"Error detaching policy: {policy_arn}")
                print(detach_result.stderr)
    else:
        print("Error listing attached policies")
        print(result.stderr)

# 역할 삭제 함수
def delete_role(role_name):
    # 역할 삭제
    result = subprocess.run([
        "aws", "iam", "delete-role",
        "--role-name", role_name
    ], capture_output=True, text=True)

    if result.returncode == 0:
        print(f"Role {role_name} deleted successfully")
    else:
        print(f"Error deleting role {role_name}")
        print(result.stderr)

# 역할 삭제 과정 함수
def delete_role_with_policies(role_name):
    # 관리형 정책 분리
    detach_managed_policies(role_name)
    
    # 역할 삭제
    delete_role(role_name)

# 역할 이름 정의
role_name = 'new_assume_role'

# 역할 삭제 호출
delete_role_with_policies(role_name)