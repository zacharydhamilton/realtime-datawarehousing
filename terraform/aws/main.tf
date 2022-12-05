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
# ------------------------------------------------------
# Local variables
# ------------------------------------------------------
locals {
    num_instances = 5
}
# ------------------------------------------------------
# Basic networking
# ------------------------------------------------------
resource "aws_default_vpc" "default_vpc" {
    tags = {
        name = "Default VPC"
    }
}
resource "random_id" "sg_id" {
    byte_length = 4
}
resource "aws_security_group" "postgres_sg" {
    name = "postgres_security_group_${random_id.sg_id.hex}"
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
        Name = "rt-dwh-postgres-sg-${random_id.sg_id.hex}"
        created_by = "terraform"
    }
}
# ------------------------------------------------------
# 'Customers' instance of Postgres
# ------------------------------------------------------
resource "random_id" "customers_id" {
    count = local.num_instances
    byte_length = 4
}
data "template_cloudinit_config" "pg_bootstrap_customers" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/pg_customers_bootstrap.sh")}"
    }
}
resource "aws_instance" "postgres_customers" {
    count = local.num_instances
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.pg_bootstrap_customers.rendered}"
    tags = {
        Name = "rt-dwh-postgres-customers-instance-${random_id.customers_id[count.index].hex}"
        created_by = "terraform"
    }
}
resource "aws_eip" "postgres_customers_ip" {
    count = local.num_instances
    vpc = true
    instance = aws_instance.postgres_customers[count.index].id
    tags = {
        Name = "rt-dwh-postgres-customers-eip-${random_id.customers_id[count.index].hex}"
        created_by = "terraform"
    }
}
# ------------------------------------------------------
# 'Products' instance of Postgres
# ------------------------------------------------------
resource "random_id" "products_id" {
    count = local.num_instances
    byte_length = 4
}
data "template_cloudinit_config" "pg_bootstrap_products" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../scripts/pg_products_bootstrap.sh")}"
    }
}
resource "aws_instance" "postgres_products" {
    count = local.num_instances
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.pg_bootstrap_products.rendered}"
    tags = {
        Name = "rt-dwh-postgres-products-instance-${random_id.products_id[count.index].hex}"
        created_by = "terraform"
    }
}
resource "aws_eip" "postgres_products_ip" {
    count = local.num_instances
    vpc = true
    instance = aws_instance.postgres_products[count.index].id
    tags = {
        Name = "rt-dwh-postgres-products-eip-${random_id.products_id[count.index].hex}"
        created_by = "terraform"
    }
}
# ------------------------------------------------------
# Outputs
# ------------------------------------------------------
output "postgres_instance_customers_public_endpoint" {
    value = ["${aws_eip.postgres_customers_ip.*.public_ip}"]
}
output "postgres_instance_products_public_endpoint" {
    value = ["${aws_eip.postgres_products_ip.*.public_ip}"]
}