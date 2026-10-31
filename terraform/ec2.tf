data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${local.name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.this.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2["web"].name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 only
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = "${local.name}-web" }
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.db_instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  key_name                    = aws_key_pair.this.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2["db"].name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  depends_on = [aws_nat_gateway.nat]
  tags       = { Name = "${local.name}-db" }
}

# Stable public address for the web server (needed at frontend build time).
resource "aws_eip" "web" {
  domain     = "vpc"
  instance   = aws_instance.web.id
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "${local.name}-web-eip" }
}

# Generates the Ansible inventory so Part 2 needs no manual editing.
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/inventory.ini.tftpl", {
    web_public_ip    = aws_eip.web.public_ip
    web_private_ip   = aws_instance.web.private_ip
    db_private_ip    = aws_instance.db.private_ip
    ssh_user         = var.ssh_user
    private_key_path = var.private_key_path
    ssh_allowed_cidr = var.allowed_ssh_cidr
  })
}
