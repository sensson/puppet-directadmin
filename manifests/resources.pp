# directadmin::resources
class directadmin::resources {
  # Create additional admin users and manage the primary one
  if $directadmin::admin_password != undef {
    user { 'admin': password => $directadmin::admin_password, }
  }
  $directadmin_admins = lookup('directadmin::admins', Hash, 'deep', {})
  create_resources(directadmin_admin, $directadmin_admins)

  # Create reseller packages
  $directadmin_reseller_packages = lookup('directadmin::reseller::packages', Hash, 'deep', {})
  create_resources(directadmin_reseller_package, $directadmin_reseller_packages)

  # Create resellers
  $directadmin_resellers = lookup('directadmin::resellers', Hash, 'deep', {})
  create_resources(directadmin_reseller, $directadmin_resellers)

  # Create user packages
  $directadmin_user_packages = lookup('directadmin::user::packages', Hash, 'deep', {})
  create_resources(directadmin_user_package, $directadmin_user_packages)
}
