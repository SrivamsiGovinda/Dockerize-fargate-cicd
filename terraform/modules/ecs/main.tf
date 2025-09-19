variable "project" {}
variable "desired_count" {}
variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "alb_target_group_arn" {}
variable "ecr_repo_url" {}
variable "region" {}

# Security group for ECS tasks
resource "aws_security_group" "ecs_task_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

# IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-ecs-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals { type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-cluster"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project}"
  retention_in_days = 7
}

# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.project
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.project
        }
      }
    }
  ])
}

# Service
resource "aws_ecs_service" "service" {
  name            = "${var.project}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.project
    container_port   = 80
  }
}