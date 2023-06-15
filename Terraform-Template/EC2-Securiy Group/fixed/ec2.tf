
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.projectname}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.subnet-az

  tags = {
    Name = "${var.projectname}-subnet"
  }
}

resource "aws_security_group" "sg" {
  name        = "${var.projectname}_EC2-SecurityGroup"
  description = "To allow Traffic to EC2"
  vpc_id      = aws_vpc.vpc.id


  tags = {
    Name = "${var.projectname}_EC2-SecurityGroup"
  }

  ingress {
    description = "SSH Allow Traffic Allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outside"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  ami                    = var.ami-id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "${var.projectname}-ec2"
  }
}