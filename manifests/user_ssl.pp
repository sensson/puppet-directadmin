# This also needs a solution so we can roll out all the certificates specifc users
# and this only works because within DirectAdmin the user has been configured to use SSL.
define directadmin::user_ssl($domain = $title, $user = '', $sslcert = '', $sslkey = '', $sslca = '') {
	# This is our certificate
	file { "/usr/local/directadmin/data/users/$user/domains/$domain.cert":
		content		=> template($sslcert),
		notify		=> Service['httpd'],
	}
		
	# Our CA
	file { "/usr/local/directadmin/data/users/$user/domains/$domain.cacert":
		content		=> template($sslca),
		notify		=> Service['httpd'],
	}
		
	# Our key
	file { "/usr/local/directadmin/data/users/$user/domains/$domain.key":
		content		=> template($sslkey),
		notify		=> Service['httpd'],
	}
}