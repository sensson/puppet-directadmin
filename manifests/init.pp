class directadmin(
	$clientid = 'none',
	$licenseid = 'none',
	$interface = 'none',
) {
	# Run some sanity checks
	if !is_numeric($directadmin::clientid) { fail("The client ID $directadmin::clientid is not a number.") }
	if !is_numeric($directadmin::licenseid) { fail("The license ID $directadmin::licenseid is not a number.") }

	class { 'directadmin::custombuild': } ->	
	class { 'directadmin::install': } 
	class { 'directadmin::services': }
	
	# Set all required options for custombuild
	$custombuild_options = hiera('directadmin::custombuild::options', {})
	create_resources(directadmin::custombuild::set, $custombuild_options)
}