import re
from datetime import datetime, timedelta
import subprocess
import json
import os

def aws_cli_login(access_key_id, secret_access_key, profile_name):
    subprocess.run(["aws", "configure", "set", "aws_access_key_id", access_key_id, "--profile", profile_name])
    subprocess.run(["aws", "configure", "set", "aws_secret_access_key", secret_access_key, "--profile", profile_name])
    print(f"AWS CLI 프로필 '{profile_name}'에 로그인되었습니다.")

def convert_to_utc(kst_time_str):
    # 'KST'와 요일 같은 불필요한 텍스트를 제거
    cleaned_time_str = re.sub(r'\s*\(.*?\)\s*', ' ', kst_time_str)  # 요일 제거
    cleaned_time_str = re.sub(r'[^\d\s.:]', '', cleaned_time_str)  # 숫자와 공백, 콜론, 점만 남기기
    cleaned_time_str = re.sub(r'\s+', ' ', cleaned_time_str).strip()  # 중복된 공백 제거
    
    # KST는 UTC+9 이므로 9시간을 빼서 UTC로 변환
    kst_time = datetime.strptime(cleaned_time_str, "%Y. %m. %d. %H:%M:%S")
    utc_time = kst_time - timedelta(hours=9)
    return utc_time.strftime("%Y-%m-%dT%H:%M:%SZ")

def read_timeline(file_path):
    with open(file_path, "r") as file:
        lines = file.readlines()
        start_time = None
        end_time = None
        for line in lines:
            if line.startswith("start"):
                start_time = line.split("start")[1].strip()
            elif line.startswith("end"):
                end_time = line.split("end")[1].strip()
        return start_time, end_time

def execute_aws_cloudtrail(start_time_kst, end_time_kst, output_file, log_Profile):
    start_time_utc = convert_to_utc(start_time_kst)
    end_time_utc = convert_to_utc(end_time_kst)
    
    # Log 폴더가 없으면 생성
    log_directory = "Log"
    if not os.path.exists(log_directory):
        os.makedirs(log_directory)
    
    # 출력 파일의 경로 설정
    output_path = os.path.join(log_directory, output_file)

    command = [
        "aws", "cloudtrail", "lookup-events",
        "--start-time", start_time_utc,
        "--end-time", end_time_utc,
        "--region", "us-east-1",
        "--output", "json",
        "--profile", log_Profile
    ]
    
    with open(output_path, "w") as outfile:
        subprocess.run(command, stdout=outfile)
        print(f"CloudTrail logs saved to {output_path}")

# JSON 파일로부터 자격 증명 가져오기
with open("origin_key.json", "r") as f:
    credentials = json.load(f)
    access_key_id = credentials.get("access_key_id")
    secret_access_key = credentials.get("secret_access_key")

# 프로필 이름을 name.txt 파일에서 읽어오기
try:
    with open("name.txt", "r") as file:
        profile_name = file.readline().strip()  # 첫 번째 줄에서 프로필 이름 읽기
except FileNotFoundError:
    print("Error: name.txt 파일을 찾을 수 없습니다.")
    exit(1)

aws_cli_login(access_key_id, secret_access_key, profile_name)

# 타임라인 파일 경로 설정
timeline_file_path = "timeline.txt"

# 타임라인에서 시작 시간과 종료 시간 읽기
start_time_kst, end_time_kst = read_timeline(timeline_file_path)

if start_time_kst and end_time_kst:
    print(f"타임라인에서 시작 시간: {start_time_kst}, 종료 시간: {end_time_kst}")
else:
    print("타임라인 파일에서 시간을 읽을 수 없습니다.")
    exit(1)

# 출력 파일 이름 입력받기
output_file = input("저장할 파일 이름 (예: cloudtrail_logs.json): ")

# CloudTrail 로그 요청 실행
execute_aws_cloudtrail(start_time_kst, end_time_kst, output_file, profile_name)