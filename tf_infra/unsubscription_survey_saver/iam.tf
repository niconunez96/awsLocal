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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}
