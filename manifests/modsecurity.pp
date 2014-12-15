#
# DirectAdmin: mod_security.
#
# We've included a patch for modsecurity that enables support for uid/gid
# per vhost such as mpm-itk and mod_ruid2. If mod_ruid2 is enabled this
# needs to be patched as well until we've got our own patch merged upstream.
#
# We're setting up log rotation as well. This is a custom script.
#

class directadmin::modsecurity(
	$modsecurity_version = '2.8.0',
	$secauditlogtype = 'Concurrent',
	$secauditlog = '/var/log/modsec_audit.log',
	$secauditlogstoragedir = '',
	$secruleengine = 'DetectionOnly',
) {
	# Url to our modsecurity patch to support mod_ruid2, this will be executed by modsecurity-install
	$modsecpatch_url = "https://gist.githubusercontent.com/ju5t/0d61ee80b23f0987d65e/raw/5adbaead0bc91bf88aa4f26d4b4285fe3105815a/modsec-712.patch"

	# Package: needed for mod_security
	package { 'expat-devel':
		ensure		=> installed,
	}

	# Exec: install mod security. Our check is based on a custom file. This allows us to do scheduled upgrades.
	# e.g. changing $modsecurity_version to a different version will do an automatic upgrade.
	exec { 'modsecurity-install':
		cwd			=> "/usr/src",
		command		=> "wget --no-check-certificate https://www.modsecurity.org/tarball/$modsecurity_version/modsecurity-$modsecurity_version.tar.gz && tar zxf modsecurity-$modsecurity_version.tar.gz && cd /usr/src/modsecurity-$modsecurity_version && wget --no-check-certificate $modsecpatch_url && patch -p1 < modsec-712.patch && ./configure && make && make install; touch /usr/lib/apache/modsecurity-$modsecurity_version",
		creates		=> "/usr/lib/apache/modsecurity-$modsecurity_version",
		require 	=> Package['expat-devel'],
		notify		=> Service['httpd'],
	}
	
	# File: ensure the mod security config file exists
	file { '/etc/httpd/conf/modsecurity.conf':
		content		=> template('directadmin/modsecurity/modsecurity.conf.erb'),
		notify		=> Service['httpd'],
		require 	=> Exec['modsecurity-install'],
	} ->
	file { '/etc/httpd/conf/unicode.mapping':
		content		=> template('directadmin/modsecurity/unicode.mapping.erb'),
		notify		=> Service['httpd'],
		require 	=> Exec['modsecurity-install'],
	} ->
	file { '/etc/httpd/conf/extra/modsec-wordpress.conf':
		content		=> template('directadmin/modsecurity/modsec-wordpress.conf.erb'),
		notify		=> Service['httpd'],
		require		=> Exec['modsecurity-install'],
	}
	
	# File_line: enable libxml2
	file_line { "enable-libxml2":
		path 		=> "/etc/httpd/conf/extra/httpd-includes.conf",
		line 		=> "LoadFile /usr/local/lib/libxml2.so",
		ensure 		=> present,
		notify 		=> Service['httpd'],
		require 	=> [ Exec['modsecurity-install'], File['/etc/httpd/conf/modsecurity.conf'], File['/etc/httpd/conf/unicode.mapping'] ],
	}
	
	# File_line: enable mod security
	file_line { "enable-modsecurity":
		path 		=> "/etc/httpd/conf/extra/httpd-includes.conf",
		line 		=> "LoadModule security2_module /usr/lib/apache/mod_security2.so",
		ensure 		=> present,
		notify 		=> Service['httpd'],
		require 	=> [ Exec['modsecurity-install'], File['/etc/httpd/conf/modsecurity.conf'], File['/etc/httpd/conf/unicode.mapping'] ],
	}
	
	# File_line: include the basic mod security config & and one to supress wordpress brute force attacks
	file_line { "enable-modsecurity-configuration":
		path 		=> "/etc/httpd/conf/extra/httpd-includes.conf",
		line 		=> "Include /etc/httpd/conf/modsecurity.conf",
		ensure 		=> present,
		notify 		=> Service['httpd'],
		require 	=> [ Exec['modsecurity-install'], File['/etc/httpd/conf/modsecurity.conf'], File['/etc/httpd/conf/unicode.mapping'] ],
	} ->
	file_line { "enable-modsecurity-configuration-wordpress":
		path		=> "/etc/httpd/conf/extra/httpd-includes.conf",
		line		=> "Include /etc/httpd/conf/extra/modsec-wordpress.conf",
		ensure		=> present,
		notify		=> Service['httpd'],
		require 	=> [ Exec['modsecurity-install'], File['/etc/httpd/conf/modsecurity.conf'], File['/etc/httpd/conf/unicode.mapping'] ],
	}
	
	# If we set SecAuditLogStorageDir variable create the right directory and set up some
	# additional scripts to ensure we're rotating logs properly.
	if $secauditlogstoragedir != '' {
		# File: create a separate log directory for concurrent log files
		file { '/var/log/modsec':
			ensure		=> directory,
			mode		=> 1733,
			require		=> Exec['modsecurity-install'],
		}
		
		# File: we concat our log files from the above directory, this is done when rotating logs
		file { '/usr/bin/modsec-logconcat.pl':
			owner		=> root,
			group		=> root,
			mode		=> 755,
			content		=> template('directadmin/modsecurity/modsec-logconcat.pl.erb'),
			require		=> Exec['modsecurity-install'],
		}
	}
	
	# File: set up log rotation
	file { '/etc/logrotate.d/modsecurity':
		owner		=> root,
		group		=> root,
		mode		=> 644,
		content		=> template('directadmin/modsecurity/modsec-logrotate.erb'),
		require		=> Exec['modsecurity-install'],
	}
}