data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  aws_region_abbrev = join(
    "",
    compact(
      regex(
        "([^-]+)-(?:(c)entral)?(?:(n)orth|(s)outh)?(?:(e)ast|(w)est)?-([^-]+)",
        data.aws_region.current.name
      )
    )
  )

  s3_bucket_prefix = "xrx-${data.aws_caller_identity.current.account_id}-${local.aws_region_abbrev}"
}
