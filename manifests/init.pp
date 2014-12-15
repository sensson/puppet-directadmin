class directadmin {
	class { 'directadmin::services': }
	
	# Package: IMAP support
	package { [ 'libc-client', 'libc-client-devel' ]:
		ensure => installed,
	}

	# Package: 
	if $operatingsystem == 'CentOS' {
		if $operatingsystemmajrelease == 6 {
			if $architecture == 'x86_64' {
				package { [ 'krb5-appl-clients.x86_64', 'krb5-appl-servers.x86_64', ]:
					ensure => installed,
				}
			}
		}
	}
	
	# Package: support for MySQL 5.5
	package { 'libaio':
		ensure		=> installed,
	}
}