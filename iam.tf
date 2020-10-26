resource "aws_iam_user" "itcfy_web_s3_uploader" {
  name = "itcfy-web-s3-uploader"
}

resource "aws_iam_access_key" "itcfy_web_s3_uploader_20201026" {
  user = aws_iam_user.itcfy_web_s3_uploader.name
}

data "aws_iam_policy_document" "itcfy_web_s3_upload" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.web.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "itcfy_web_s3_upload" {
  name   = "itcfy-web-s3-upload"
  path   = "/"
  policy = data.aws_iam_policy_document.itcfy_web_s3_upload.json
}

resource "aws_iam_user_policy_attachment" "itcfy_web_s3_uploader_policy" {
  user       = aws_iam_user.itcfy_web_s3_uploader.name
  policy_arn = aws_iam_policy.itcfy_web_s3_upload.arn
}
