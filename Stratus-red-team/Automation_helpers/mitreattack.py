import json
import os
from tkinter import Tk
from tkinter.filedialog import askdirectory

# MITRE ATT&CK 매핑 테이블
mitre_attack_mapping = {
    
}

# tkinter GUI 창을 숨기기 위한 설정
Tk().withdraw()

# 폴더 선택 창 띄우기
log_directory = askdirectory(title="로그 파일이 있는 폴더를 선택하세요")

if not log_directory:
    print("폴더가 선택되지 않았습니다. 프로그램을 종료합니다.")
    exit()

# 디렉토리 내 모든 로그 파일 읽기
for filename in os.listdir(log_directory):
    if filename.endswith(".json"):
        file_path = os.path.join(log_directory, filename)
        
        # 로그 파일 열기
        with open(file_path, 'r') as file:
            log_data = json.load(file)
        
        # log_data가 리스트인 경우 처리
        if isinstance(log_data, list):
            for event in log_data:
                event_name = event.get("eventName")
                if event_name in mitre_attack_mapping:
                    # MITRE ATT&CK 매핑 정보 추가
                    event["mitreAttackTactic"] = mitre_attack_mapping[event_name]["Tactic"]
                    event["mitreAttackTechnique"] = mitre_attack_mapping[event_name]["Technique"]
        
        # 수정된 로그 데이터를 같은 파일에 덮어쓰기
        with open(file_path, 'w') as file:
            json.dump(log_data, file, indent=4)

print(f"로그 파일에 MITRE ATT&CK 매핑이 완료되었습니다.")
