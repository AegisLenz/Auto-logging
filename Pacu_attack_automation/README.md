## Pacu_attack_automation

# Setting
- 로그를 뽑기 위해서는 권한을 가진 계정으로 origin.json을 만들어 둬야함
- terraform이 설치되어있어야함

# Usage
- 공격별로 Exploit.sh가 존재
- 권한이 없다면 chmod +x를 이용해서 .sh 파일에 권한 주기

- 로그를 다운받고 싶다면 두가지 옵션이 있음
  1. logging.py 이용 -> 시간 입력
  2. logging.sh 이용 -> 시간 timeline.txt 이용

- 로그추출 두개의 포맷이 다름
1. Py :
9월 10, 2024, 18:36:28

2. Sh :
  - start 2024년 9월 14일 토요일 16시 50분 11초 KST
  - end 2024년 9월 14일 토요일 16시 50분 17초 KST
