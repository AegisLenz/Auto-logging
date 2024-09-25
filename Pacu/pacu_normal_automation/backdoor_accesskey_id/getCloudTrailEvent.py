import json

def extract_cloudtrail_events(input_file_path, output_file_path):
    with open(input_file_path, 'r') as f:
        data = json.load(f)
    
    cloudtrail_events = [json.loads(event["CloudTrailEvent"]) for event in data["Events"]]
    
    with open(output_file_path, 'w') as f:
        json.dump(cloudtrail_events, f, indent=4)


input_file_path = '변경_전_로그주소'
output_file_path = '변경_후_로그주소'
extract_cloudtrail_events(input_file_path, output_file_path)
