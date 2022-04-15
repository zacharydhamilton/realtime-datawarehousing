data "template_cloudinit_config" "bootstrap" {
    base64_encode = true
    part {
        content_type = "text/x-shellscript"
        content = "${file("../setup/commands.sh")}"
    }
}

resource "aws_instance" "postgres" {
    ami = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    security_groups = [aws_security_group.postgres_sg.name]
    user_data = "${data.template_cloudinit_config.bootstrap.rendered}"
    tags = {
        name = "rt-dwh-postgres-instance"
        created_by = "terraform"
    }
}

output "postgres_instance_dns_endpoint" {
    value = aws_instance.postgres.public_dns
}