#!/bin/bash

# 첫 번째 파이썬 스크립트 실행
# python3 generate_terraform.py

# 두 번째 파이썬 스크립트 실행
# python3 run_terraform.py
echo "start $(date)" >> ./timeline.txt
python3 normal.py

# python3 DelRole.py
# python3 destroy.py
echo "end $(date)" >> ./timeline.txt