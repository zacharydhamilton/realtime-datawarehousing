resource "aws_default_vpc" "default_vpc" {
    tags = {
        name = "Default VPC"
    }
}

resource "aws_security_group" "postgres_sg" {
    name = "postgres_security_group"
    description = "Security Group for Postgres EC2 instance. Used in Confluent Cloud Realtime Datawarehouse Ingestion workshop."
    vpc_id = aws_default_vpc.default_vpc.id
    egress {
        description = "Allow all outbound."
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
    }
    ingress {
        description = "Postgres"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
    }
    tags = {
        name = "rt-dwh-postgres-sg"
        created_by = "terraform"
    }
}