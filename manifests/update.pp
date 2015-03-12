class directadmin::update inherits directadmin {
	if $::directadmin::auto_update == true {
		exec { 'update-versions':
			cwd		=> '/usr/local/directadmin/custombuild',
			command	=> '/usr/local/directadmin/custombuild/build update_versions',
			unless	=> '/usr/local/directadmin/custombuild/build update && /usr/local/directadmin/custombuild/build versions',
		}
	}
}