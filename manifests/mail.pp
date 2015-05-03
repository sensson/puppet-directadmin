class directadmin::mail(
	$mail_limit = 200,
	$sa_updates = true,
	$php_imap = false,
) {
	# File change: set up our e-mail limit
	file { "/etc/virtual/limit":
		owner => mail,
		group => mail,
		mode => 644,
		ensure => present,

		# maximum e-mails per day, it needs quotes to ensure it gets 
		# read correctly, Hiera will set as an integer for example
		content => "$mail_limit",

		# restart on change
		notify => Service['exim'],
		require => Exec['directadmin-installer'],
	} ->
	# File change: /etc/virtual/limit_unknown
	file { "/etc/virtual/limit_unknown":
		owner => mail,
		group => mail,
		mode => 644,
		ensure => present,
		content => 0,
		notify => Service['exim'],
		require => Exec['directadmin-installer'],
	}

	# Install support for imap in php if required
	if $php_imap == true {
		exec { "directadmin-download-php-imap":
			cwd 	=> "/root",
			command => "wget -O /root/imap_php.sh files.directadmin.com/services/all/imap_php.sh && chmod +x /root/imap_php.sh",
			creates => "/root/imap_php.sh",
			require => Exec['directadmin-installer'],
		} ->
		exec { "directadmin-install-php-imap":
			cwd		=> "/root",
			command => "/root/imap_php.sh",
			unless	=> "php -i | grep imap | wc -l | grep -c 3",
			require => Exec['directadmin-installer'],
			timeout => 0,
		}
	}	
	# SpamAssassin cron jobs
	if $sa_updates == true {
		$sa_cron = 'present'
	} else {
		$sa_cron = 'absent'
	}
	
	# Cron: daily update of SpamAssassin rules
	cron { 'exim-sa-update': 
		command => "/usr/bin/sa-update; /sbin/service exim restart",
		user => root,
		hour => 7,
		minute => 5,
		ensure => $sa_cron,
		require => Exec['directadmin-installer'],
	}
}