import boto3
import json
from botocore.exceptions import ClientError

def create_second_access_key():
    # access_key.json에서 Access Key ID와 Secret Access Key 읽기
    with open('access_key.json', 'r') as f:
        keys = json.load(f)

    access_key_id = keys.get('access_key_id')
    secret_access_key = keys.get('secret_access_key')

    # name.txt에서 사용자 이름 읽기
    with open('name.txt', 'r') as f:
        user_name = f.read().strip()

    # Boto3 IAM 클라이언트 생성
    iam_client = boto3.client(
        'iam',
        aws_access_key_id=access_key_id,
        aws_secret_access_key=secret_access_key
    )

    try:
        # 현재 사용자의 Access Key 리스트 가져오기
        response = iam_client.list_access_keys(UserName=user_name)
        access_keys = response['AccessKeyMetadata']
        
        # 이미 두 개의 Access Key가 존재하는지 확인
        if len(access_keys) >= 2:
            print(f"{user_name} 사용자는 이미 2개의 액세스 키를 가지고 있습니다. 추가 생성 불가.")
            return

        # 두 번째 Access Key 생성
        new_access_key = iam_client.create_access_key(UserName=user_name)

        # 생성된 Access Key 정보 출력
        print(f"Access Key ID: {new_access_key['AccessKey']['AccessKeyId']}")
        print(f"Secret Access Key: {new_access_key['AccessKey']['SecretAccessKey']}")

        # 새로운 Access Key를 access_key.json에 저장
        keys['new_access_key_id'] = new_access_key['AccessKey']['AccessKeyId']
        keys['new_secret_access_key'] = new_access_key['AccessKey']['SecretAccessKey']

        with open('access_key.json', 'w') as f:
            json.dump(keys, f, indent=4)

        print("두 번째 액세스 키가 성공적으로 생성되었으며, access_key.json에 저장되었습니다.")

    except ClientError as e:
        print(f"오류 발생: {e}")

if __name__ == "__main__":
    create_second_access_key()
