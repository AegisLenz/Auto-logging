import subprocess
import json
import os

def aws_cli_login(access_key_id, secret_access_key, profile_name):
    # AWS CLI에 Access Key와 Secret Access Key 설정
    subprocess.run(["aws", "configure","set", "aws_access_key_id", access_key_id, "--profile", profile_name])
    subprocess.run(["aws", "configure", "set", "aws_secret_access_key", secret_access_key, "--profile", profile_name])
    print(f"AWS CLI 프로필 '{profile_name}'에 로그인되었습니다.")

def get_user_id(profile_name):
    # 'aws sts get-caller-identity' 명령 실행
    result = subprocess.run(["aws", "sts", "get-caller-identity", "--profile", profile_name], capture_output=True, text=True)
    
    # 명령 실행에 실패한 경우 오류 메시지 출력
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return None

    # 결과를 JSON으로 파싱
    try:
        identity = json.loads(result.stdout)
        user_id = identity.get("UserId", None)
        return user_id
    except json.JSONDecodeError as e:
        print("Error decoding JSON:", e)
        return None

if __name__ == "__main__":
    # name.txt에서 최신 IAM 사용자 이름(프로필 이름) 읽기
    try:
        with open("name.txt", "r") as file:
            profile_name = file.readline().strip()  # 첫 번째 줄에서 프로필 이름 읽기
    except FileNotFoundError:
        print("Error: name.txt 파일을 찾을 수 없습니다.")
        exit(1)

    # access_key.json에서 자격 증명 불러오기
    try:
        with open("access_key.json", "r") as f:
            credentials = json.load(f)
            access_key_id = credentials.get("access_key_id")
            secret_access_key = credentials.get("secret_access_key")
    except FileNotFoundError:
        print("Error: access_key.json 파일을 찾을 수 없습니다.")
        exit(1)

    # Access Key가 존재하는지 확인
    if access_key_id and secret_access_key:
        # AWS CLI에 로그인
        aws_cli_login(access_key_id, secret_access_key, profile_name)
        
        # 로그인한 사용자 정보 가져오기
        user_id = get_user_id(profile_name)
        if user_id:
            print(f"User ID: {user_id}")
        else:
            print("User ID를 가져올 수 없습니다.")
    else:
        print("Access Key 정보를 불러오지 못했습니다.")
