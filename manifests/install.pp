class directadmin::install inherits directadmin {
	# Decide which interface to use
	if $directadmin::interface == 'none' {
		if has_interface_with('venet0') { $directadmin_interface = 'venet0:0' }
		else { $directadmin_interface = 'eth0'}
	} else {
		$directadmin_interface = $directadmin::interface
	}
	
	# The installation URL and a set of base packages that we need to install
	$directadmin_installer = "http://www.directadmin.com/setup.sh"
	$directadmin_packages = [ 
		"gcc", "gcc-c++", "flex", "bison", "make", "bind", "bind-libs", 
		"openssl", "openssl-devel", "quota", "libaio", 
		"libcom_err-devel", "libcurl-devel", "gd", "zlib-devel", "zip", "unzip", 
		"libcap-devel", "cronie", "bzip2", "cyrus-sasl-devel", "perl-ExtUtils-Embed",
		"autoconf", "automake", "libtool", "which", "patch", "mailx", "db4-devel", 
		"perl-ExtUtils-MakeMaker", "perl-Digest-SHA", "perl-Net-DNS", "perl-NetAddr-IP", 
		"perl-Archive-Tar", "perl-IO-Zlib", "perl-Mail-SPF", "perl-IO-Socket-INET6",
		"perl-IO-Socket-SSL", "perl-Mail-DKIM", "perl-DBI", "perl-Encode-Detect", 
		"perl-HTML-Parser", "perl-HTML-Tagset", "perl-Time-HiRes", "perl-libwww-perl",
	]
	
	# Package: required packages for DirectAdmin, they need to be installed first
	package { $directadmin_packages:	
		ensure	=> installed,
	} ->
	
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

	# Exec: set up the installation files
	exec { 'directadmin-download-installer':
		cwd 	=> "/root",
		command	=> "wget -O setup.sh --no-check-certificate $directadmin_installer && chmod +x /root/setup.sh",
		creates	=> "/root/setup.sh",
	}

	# Exec: install DirectAdmin	
	exec { 'directadmin-installer':
		cwd		=> "/root",
		command	=> "/root/setup.sh $directadmin::clientid $directadmin::licenseid $::fqdn $directadmin_interface",
		require	=> [ Exec['directadmin-download-installer'], Package[$directadmin_packages], Class['directadmin::custombuild::options'], ],
		creates => '/usr/local/directadmin/conf/directadmin.conf',
		timeout => 0,
	}
	
}