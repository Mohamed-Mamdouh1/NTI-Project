# output "alb_dns_name" {
#   description = "Public URL for the load balancer"
#   value       = aws_lb.nti_alb.dns_name
# }
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.nti_cluster.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.nti_cluster.name
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.nti_cluster.certificate_authority[0].data
}
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.nti_alb.dns_name
}
