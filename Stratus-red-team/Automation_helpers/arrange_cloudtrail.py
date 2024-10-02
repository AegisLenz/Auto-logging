import os
import json

def extract_cloudtrail_events_from_all_files(input_directory, output_directory):
    # 출력 디렉토리가 존재하지 않으면 생성
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # 입력 디렉토리 내의 모든 파일 순회
    for root, dirs, files in os.walk(input_directory):
        for file in files:
            # 파일이 JSON 파일인지 확인
            if file.endswith(".json"):
                input_file_path = os.path.join(root, file)
                output_file_path = os.path.join(output_directory, f"extracted_{file}")
                
                try:
                    # 입력 파일에서 CloudTrailEvent 필드 추출
                    with open(input_file_path, 'r') as f:
                        data = json.load(f)
                    
                    # CloudTrail 이벤트 추출
                    cloudtrail_events = [json.loads(event["CloudTrailEvent"]) for event in data.get("Events", [])]
                    
                    # 출력 파일에 추출된 이벤트 저장
                    with open(output_file_path, 'w') as f:
                        json.dump(cloudtrail_events, f, indent=4)
                    
                    print(f"Successfully extracted events from {input_file_path} to {output_file_path}")

                except Exception as e:
                    print(f"Error processing file {input_file_path}: {e}")

# 입력 디렉토리 경로 설정 (모든 JSON 파일이 있는 최상위 디렉토리)
input_directory = ""

# 출력 디렉토리 경로 설정 (추출된 이벤트를 저장할 디렉토리)
output_directory = ""

# 함수 호출
extract_cloudtrail_events_from_all_files(input_directory, output_directory)