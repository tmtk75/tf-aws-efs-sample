resource "aws_efs_file_system" "efs-test" {
    reference_name = "efs-test"
    tags {
       Name = "efs-test"
    }
}

resource "aws_security_group" "target" {
    name        = "${var.efs_test_name}-target"
    description = "${var.efs_test_name}-target"
    vpc_id      = "${var.vpc_id}"
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 2049
        to_port         = 2049
        protocol        = "tcp"
	security_groups = [ "${aws_security_group.efs-test.id}" ]
    }
    tags = {
        Name = "${var.efs_test_name}"
    }
}

resource "aws_efs_mount_target" "alpha" {
    file_system_id  = "${aws_efs_file_system.efs-test.id}"
    subnet_id       = "${var.subnet_id_c}"
    security_groups = [ "${aws_security_group.target.id}" ]
}

output efs_id { value = "${aws_efs_file_system.efs-test.id}" }
