output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.cluster.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.cluster.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.this.*.name
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = aws_autoscaling_group.workers.*.arn
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = aws_autoscaling_group.workers.*.id
}

output "workers_user_data" {
  description = "User data of worker groups"
  value       = data.template_file.userdata.*.rendered
}

output "workers_default_ami_id" {
  description = "ID of the default worker group AMI"
  value       = data.aws_ami.eks_worker.id
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = aws_security_group.workers.id
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value       = aws_iam_instance_profile.workers.*.arn
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value       = aws_iam_instance_profile.workers.*.name
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = aws_iam_role.workers.*.name
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = aws_iam_role.workers.*.arn
}

