terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}



resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet_id.id
  route_table_id = aws_route_table.public.id
}





resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "medusa-backendserver"
  }
}
resource "aws_subnet" "subnet_id" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  

  map_public_ip_on_launch = true
  tags = {
    Name = "main-subnet"
  }
}
resource "aws_security_group" "sg_id" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5433
    to_port     = 5433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-security-group"
  }
}

resource "aws_ecs_task_definition" "pearlthoughts_medusa_backend" {
  family                   = "pearlthoughts_medusa_backend"
  execution_role_arn       = aws_iam_role.role_for_the_ecs_tasks.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions    = jsonencode([{
    name      = "medusa_backend"
    image     =  "nagaraju7876482/medus-backend-server-repo:latest"
    essential = true
    portMappings = [{
      containerPort = 9000
      hostPort      = 9000
    }]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "postgres://postgres:Maven123@192.168.1.3:5433/postgres"
      }
    ]
  }])
}


resource "aws_ecs_service" "pearlthoughts_medusa" {
  name            = "pearlthoughts_medusa-service"
  cluster         = aws_ecs_cluster.cluster_to_deploy_the_containers.id
  task_definition = aws_ecs_task_definition.pearlthoughts_medusa_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_id.id]
    security_groups  = [aws_security_group.sg_id.id]
    assign_public_ip = true
  }

  
}

