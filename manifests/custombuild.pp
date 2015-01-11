class directadmin::custombuild {
	# File: set up the required directories, we need to ensure they exist
	file { [ "/usr/local/directadmin", "/usr/local/directadmin/custombuild", ]:
		ensure => directory,
	}
}