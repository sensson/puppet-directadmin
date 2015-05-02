class directadmin::resources {
	# Create additional admin users and manage the primary one
	user { 'admin': password => $directadmin::admin_password, }
	$directadmin_admins = hiera('directadmin::admins', {})
	create_resources(directadmin_admin, $directadmin_admins)

	# Create reseller packages
	$directadmin_reseller_packages = hiera('directadmin::reseller::packages', {})
	create_resources(directadmin_reseller_package, $directadmin_reseller_packages)

	# Create resellers
	$directadmin_resellers = hiera('directadmin::resellers', {})
	create_resources(directadmin_reseller, $directadmin_resellers)

	# Create user packages
	$directadmin_user_packages = hiera('directadmin::user::packages', {})
	create_resources(directadmin_user_package, $directadmin_user_packages)
}