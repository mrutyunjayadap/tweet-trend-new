resource "aws_security_group" "worker_node_sg" {
  name        = "eks-test"
  description = "Allow ssh inbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description      = "ssh access to public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}



resource "aws_vpc_security_group_ingress_rule" "allow_30082" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30082
  ip_protocol       = "tcp"
  to_port           = 30082
  description       = "kube access"
}