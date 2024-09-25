import os

def clear_credentials_file():
    # ~/.aws/credentials 파일 경로
    credentials_file_path = os.path.expanduser("~/.aws/credentials")

    # credentials 파일이 존재하는지 확인
    if os.path.exists(credentials_file_path):
        # 파일 내용을 비움
        with open(credentials_file_path, "w") as f:
            f.write("")  # 빈 문자열을 기록하여 파일 내용을 비움
        print("~/.aws/credentials 파일의 내용이 삭제되었습니다.")
    else:
        print("~/.aws/credentials 파일을 찾을 수 없습니다.")

if __name__ == "__main__":
    clear_credentials_file()
