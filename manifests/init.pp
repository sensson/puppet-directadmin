class directadmin(
	$clientid = 'none',
	$licenseid = 'none',
	$interface = 'none',
	$auto_update = false,
) {
	# Run some sanity checks
	if !is_numeric($directadmin::clientid) { fail("The client ID $directadmin::clientid is not a number.") }
	if !is_numeric($directadmin::licenseid) { fail("The license ID $directadmin::licenseid is not a number.") }

	class { 'directadmin::custombuild': } ->	
	class { 'directadmin::install': } ->
	class { 'directadmin::update': }
	class { 'directadmin::services': }
	
	# Set all required options for custombuild
	$custombuild_options = hiera('directadmin::custombuild::options', {})
	create_resources(directadmin::custombuild::set, $custombuild_options)
	
	# Set all required configuration settings
	$directadmin_config = hiera('directadmin::config::options', {})
	create_resources(directadmin::config::set, $directadmin_config)
}