output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_public_id" {
  value = google_compute_subnetwork.subnet_public.id
}

output "subnet_public_name" {
  value = google_compute_subnetwork.subnet_public.name
}

output "subnet_private_id" {
  value = google_compute_subnetwork.subnet_private.id
}

output "subnet_private_name" {
  value = google_compute_subnetwork.subnet_private.name
}

output "subnet_full_access_name" {
  value = google_compute_subnetwork.subnet_full_access.name
}

# output "private_key" {
#   value     = tls_private_key.ssh_key.private_key_pem
#   sensitive = true # Помечаем как чувствительное значение, чтобы не выводить в лог
# }