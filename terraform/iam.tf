data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# One role + instance profile per server, so permissions can diverge later.
locals {
  roles = toset(["web", "db"])
}

resource "aws_iam_role" "ec2" {
  for_each           = local.roles
  name               = "${local.name}-${each.key}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Session Manager access (shell without opening SSH) and node metrics/logs.
resource "aws_iam_role_policy_attachment" "ssm" {
  for_each   = local.roles
  role       = aws_iam_role.ec2[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  for_each   = local.roles
  role       = aws_iam_role.ec2[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  for_each = local.roles
  name     = "${local.name}-${each.key}-profile"
  role     = aws_iam_role.ec2[each.key].name
}
