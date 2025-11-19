# Triggering workflow again
# Latest Ubuntu AMI (Canonical)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Subnets in the default VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group allowing SSH, HTTP, HTTPS
resource "aws_security_group" "web_sg" {
  name        = "terraform-nginx-sg"
  description = "Allow SSH, HTTP, and HTTPS"   # <-- updated to match AWS exactly
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # for testing only; restrict to your IP for production
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-nginx-sg"
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_subnets.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx git
              systemctl enable nginx
              systemctl start nginx

              # Optional: clone a GitHub site into /var/www/website if you want
              # Replace the URL below with your repo if desired (uncomment)
              # cd /var/www
              # git clone https://github.com/<your-username>/<your-repo>.git website
              # chown -R www-data:www-data /var/www/website

              # create a simple index page if repo not present
              if [ ! -f /var/www/html/index.html ]; then
                echo "<html><body><h1>Hello from Terraform + Nginx on $(hostname)</h1></body></html>" > /var/www/html/index.html
                chown www-data:www-data /var/www/html/index.html
              fi
              EOF

  tags = {
    Name = "terraform-nginx-instance"
  }
}
