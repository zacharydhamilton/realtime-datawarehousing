terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "us-east-2"
}
resource "aws_default_vpc" "default_vpc" {
    tags = {
        name = "Default VPC"
    }
}
resource "aws_security_group" "postgres_sg" {
    name = "postgres_security_group_attendees_${split("-", uuid())[0]}"
    description = "Security Group for Postgres EC2 instance. Used in Confluent Cloud Realtime Datawarehouse Ingestion workshop."
    vpc_id = aws_default_vpc.default_vpc.id
    egress {
        description = "Allow all outbound."
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Postgres"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Postgres"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
        Name = "rt-dwh-postgres-attendee-sg"
        created_by = "terraform"
    }
}
resource "aws_security_group" "mysql_sg" {
    name = "mysql_security_group_attendees_${split("-", uuid())[0]}"
    description = "Security Group for MySQL EC2 instance. Used in Confluent Cloud Realtime Datawarehouse Ingestion workshop."
    vpc_id = aws_default_vpc.default_vpc.id
    egress {
        description = "Allow all outbound."
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Mysql"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Mysql"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
        Name = "rt-dwh-mysql-attendee-sg"
        created_by = "terraform"
    }
}
data "template_cloudinit_config" "pg_bootstrap" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/pg_commands.sh")}"
    }
}
resource "aws_instance" "postgres" {
    count = 5
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.xlarge"
    associate_public_ip_address = true
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.pg_bootstrap.rendered}"
    tags = {
        Name = "rt-dwh-postgres-attendee-instance-${count.index}"
        created_by = "terraform"
    }
}
output "postgres_instance_public_endpoint" {
    value = ["${aws_instance.postgres.*.public_ip}"]
}
data "template_cloudinit_config" "ms_bootstrap" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/ms_commands.sh")}"
    }
}
resource "aws_instance" "mysql" {
    count = 5
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.xlarge"
    associate_public_ip_address = true
    security_groups = [aws_security_group.mysql_sg.name]
    user_data = "${data.template_cloudinit_config.ms_bootstrap.rendered}"
    tags = {
        Name = "rt-dwh-mysql-attendee-instance-${count.index}"
        created_by = "terraform"
    }
}
output "mysql_instance_public_endpoint" {
    value = ["${aws_instance.mysql.*.public_ip}"]
}