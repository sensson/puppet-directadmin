class directadmin(
	$clientid = 'none',
	$licenseid = 'none',
	$interface = 'none',
	$auto_update = false,
	$admin_password = '',
) {
	# Run some sanity checks
	if !is_numeric($directadmin::clientid) { fail("The client ID $directadmin::clientid is not a number.") }
	if !is_numeric($directadmin::licenseid) { fail("The license ID $directadmin::licenseid is not a number.") }
	if $directadmin::admin_password == '' { fail("An admin password must be specified.") }

	class { 'directadmin::custombuild': } ->	
	class { 'directadmin::install': } ->
	class { 'directadmin::update': }
	class { 'directadmin::services': }
	class { 'directadmin::resources': }
	
	# Set all required options for custombuild
	$custombuild_options = hiera('directadmin::custombuild::options', {})
	create_resources(directadmin::custombuild::set, $custombuild_options)
	
	# Set all required configuration settings
	$directadmin_config = hiera('directadmin::config::options', {})
	create_resources(directadmin::config::set, $directadmin_config)

	# Set up the chain that defines when to run which resources, this can cause a dependency cycle
	# so we may need to refactor this in the future
	Exec['directadmin-installer'] -> Service['directadmin'] -> User <| |> -> 
	Directadmin_admin <| |> -> Directadmin_reseller_package <| |> -> 
	Directadmin_reseller <| |> -> Directadmin_user_package <| |>
}