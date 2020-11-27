resource "random_id" "creation_token" {
  byte_length = 8
  prefix      = "${var.efs-name}-"
}

resource "aws_efs_file_system" "this" {
  creation_token = random_id.creation_token.hex

  tags = {
    Name          = var.efs-name
    CreationToken = random_id.creation_token.hex
    terraform     = "true"
  }
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet-efs.id
  security_groups = [aws_security_group.mount_target.id]
}

resource "aws_security_group" "mount_target_client" {
  name        = "${var.efs-name}-mount-target-client"
  description = "Allow traffic out to NFS for ${var.efs-name}-mnt."
  vpc_id      = var.vpc_id

  depends_on = [aws_efs_mount_target.this]

  tags = {
    Name      = "${var.efs-name}-mount-target-client"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs_egress" {
  description              = "Allow NFS traffic out from EC2 to mount target"
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mount_target_client.id
  source_security_group_id = aws_security_group.mount_target.id
}

resource "aws_security_group" "mount_target" {
  name        = "${var.efs-name}-mount-target"
  description = "Allow traffic from instances using ${var.efs-name}-ec2."
  vpc_id      = var.vpc_id

  tags = {
    Name      = "${var.efs-name}-mount-target"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs_ingress" {
  description              = "Allow NFS traffic into mount target from EC2"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mount_target.id
  source_security_group_id = aws_security_group.mount_target_client.id
}