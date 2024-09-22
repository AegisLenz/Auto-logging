provider "aws" {
  region = "us-east-1"
}

# Create a new IAM user
resource "aws_iam_user" "new_user" {
  name = "new_user"
}

# Create a new IAM role (AssumeRole 정책은 Python 코드에서 처리)
resource "aws_iam_role" "new_role" {
  name = "new_assume_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "${aws_iam_user.new_user.arn}"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create a new IAM policy for the role
resource "aws_iam_policy" "new_policy" {
  name        = "new_policy"
  description = "A policy for new_role"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the new role
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.new_role.name
  policy_arn = aws_iam_policy.new_policy.arn
}

# Attach the policy to the new user (Python 코드에서 생성한 역할에 접근할 수 있도록)
resource "aws_iam_user_policy_attachment" "new_user_policy_attach" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.new_policy.arn
}

# Create access key for the new IAM user
resource "aws_iam_access_key" "new_user_access_key" {
  user = aws_iam_user.new_user.name
}