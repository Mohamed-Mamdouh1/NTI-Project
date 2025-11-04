data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID

  filter {
    name   = "name"
    # Use the pattern verified by the CLI command
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu_2404.id # Use the dynamic AMI ID
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public1.id
  key_name      = "nti-key"   

  tags = {
    Name = "jenkins-server"
  }
}