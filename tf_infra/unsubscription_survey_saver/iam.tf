data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "lambda_sns_publish" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]
    resources = [aws_sns_topic.unsubscription_survey_submitted.arn]
  }
}

resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "lambda_sns_publish"
  path        = "/"
  description = "IAM policy for publishing into unsubscription survey submitted"
  policy      = data.aws_iam_policy_document.lambda_sns_publish.json
}

resource "aws_iam_role_policy_attachment" "lambda_sns_publish" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}

data "aws_iam_policy_document" "lambda_dynamodb_write" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Write",
    ]
    resources = [aws_dynamodb_table.unsubscription_survey.arn]
  }
}

resource "aws_iam_policy" "lambda_dynamodb_write" {
  name        = "lambda_dynamodb_write"
  path        = "/"
  description = "IAM policy for writting into UnsubscriptionSurvey table"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_write.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_write" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_dynamodb_write.arn
}
