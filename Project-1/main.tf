provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "mysg" {
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

resource "aws_instance" "my-instance" {
    ami = "ami-0440d3b780d96b29d"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.mysg.name ]
    user_data = "${file("script.sh")}"
    key_name = "login"
}

resource "aws_ec2_tag" "tag" {
    resource_id = aws_instance.my-instance.id
    key = "Name"
    value = "Server"
}

output "ec2_global_ips" {
    value = "${aws_instance.my-instance.*.public_ip}"
}
