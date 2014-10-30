class directadmin::services {
	# Service: exim, our e-mail server
	service { 'exim':
		ensure		=> running,
		enable		=> true,
		hasrestart 	=> true,
	}
	
	# Service: dovecot, our POP/IMAP server
	service { 'dovecot':
		ensure		=> running,
		enable		=> true,
		hasrestart	=> true,
	}
	
	# Service: apache, our web server
	service { 'httpd':
		ensure		=> running,
		enable		=> true,
		hasrestart	=> true,
	}
	
	# Service: directadmin, our control panel
	service { 'directadmin':
		ensure		=> running,
		enable		=> true,
		hasrestart	=> true,
	}
}