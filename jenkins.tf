data "aws_vpc" "selected" {
  tags = {Name = "account-infrastructure-vpc"}
}

output "VPCid" {
   value = data.aws_vpc.selected.id

}
resource "aws_security_group" "JenkinsSG" {
  name = "Jenkins_SG"
	vpc_id      = data.aws_vpc.selected.id
	
	
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "JenkinsEC2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
	subnet_id = "subnet-02985b49c8db377ed"
	
  key_name   = "terraform_keypair"
	
	
  tags = {
    Name = "terraform-jenkins-master"
  }
  user_data = file("userdata.sh")

}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]

}

output "jenkins_endpoint" {
  value = formatlist("http://%s:%s/", aws_instance.JenkinsEC2.*.public_ip, "8080")
}