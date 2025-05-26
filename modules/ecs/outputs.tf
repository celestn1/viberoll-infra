#-------------------------
# viberoll-infra/modules/rds/outputs.tf
#------------------------- 

output "ecs_cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "The ECS Cluster ID"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "The name of the ECS Service"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "The ARN of the ECS Task Definition"
}
