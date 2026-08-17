output "disabled_updates_ignition" {
  value       = data.ct_config.disabled_updates.rendered
  description = "Ignition config for a DHCP machine with Zincati disabled."
}

output "periodic_updates_ignition" {
  value       = data.ct_config.periodic_updates.rendered
  description = "Ignition config for a static IP machine with periodic Zincati updates."
}

output "immediate_updates_ignition" {
  value       = data.ct_config.immediate_updates.rendered
  description = "Ignition config for a DHCP machine with immediate Zincati updates."
}
