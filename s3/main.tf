# create "s3 bucknet"

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-buck"
  acl    = "private"

  versioning = {
    enabled = true
  }

}