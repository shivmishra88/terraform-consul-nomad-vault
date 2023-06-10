resource "aws_instance" "ec2" {
  count = 7
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  private_ip             = "${var.cnv_ip_range}${count.index+10}"
  tags = {
        Name = "CNV-${count.index}"
        Role = count.index < 3 ? "server" : "client"
    }
    root_block_device {
    volume_size = var.cnv_volume_size
    volume_type = "gp3"
    }
    user_data = file("${path.module}/../../base_install.sh")
}