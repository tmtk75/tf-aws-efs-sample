/* */
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vpc_id"      {}
variable "subnet_id_c" {}
variable "cidr"        {}
variable "aws_region" { default = "us-west-2" }
variable "efs_test_name" { default = "efs-test" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

resource "aws_security_group" "efs-test" {
    name        = "${var.efs_test_name}"
    description = "${var.efs_test_name}"
    vpc_id      = "${var.vpc_id}"
    egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "${var.cidr}/32" ]
    }
    tags = {
        Name = "${var.efs_test_name}"
    }
}

resource "aws_key_pair" "efs-test" {
    key_name   = "efs-test"
    public_key = "${file("id_rsa.pub")}"
}

resource "aws_instance" "efs-test" {
    ami                         = "ami-d2c924b2"  # CentOS7: https://aws.amazon.com/marketplace/ordering?productId=b7ee8a69-ee97-4a49-9e68-afaee216db2e&ref_=dtl_psb_continue&region=ap-northeast-1
    instance_type               = "t2.nano"
    key_name                    = "${aws_key_pair.efs-test.key_name}"
    security_groups             = [ "${aws_security_group.efs-test.id}" ]
    subnet_id                   = "${var.subnet_id_c}"
    iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
    associate_public_ip_address = true
    disable_api_termination     = false
    count                       = 2

    root_block_device {
        volume_size = 20
    }
    ephemeral_block_device {
        device_name = "/dev/sdb"
        virtual_name = "ephemeral0"
    }
    tags {
        Name         = "${var.efs_test_name}.${count.index}"
        efs_test_name = "${var.efs_test_name}"
    }
}

output node0 { value = "${aws_instance.efs-test.0.public_dns}" }
output node1 { value = "${aws_instance.efs-test.1.public_dns}" }

