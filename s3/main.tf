# create "s3 bucknet"

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "vtalent-11"
  acl    = "private"

  versioning = {
    enabled = true
  }

}