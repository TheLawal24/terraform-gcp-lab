output "instance_name" {
  value = module.compute_vm.name
}

output "external_ip" {
  value = module.compute_vm.external_ip
}

output "internal_ip" {
  value = module.compute_vm.internal_ip
}

output "network_name" {
  value = google_compute_network.devops_vpc.name
}

output "network_self_link" {
  value = google_compute_network.devops_vpc.self_link
}

output "subnet_name" {
  value = google_compute_subnetwork.devops_subnet.name
}

output "subnet_cidr" {
  value = google_compute_subnetwork.devops_subnet.ip_cidr_range
}

output "deployment_name" {
  value = local.deployment_name
}

output "environment_tier" {
  value = local.environment_labels.tier
}
