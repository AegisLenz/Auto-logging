#!/bin/bash

# 시작 시간 기록
echo "start $(date)" >> timeline.txt

# 첫 번째 파이썬 스크립트 실행
python3 generate_terraform.py

# 두 번째 파이썬 스크립트 실행
python3 run_terraform.py

sleep 2