class directadmin::mail(
	$mail_limit = 200,
	$sa_updates = true,
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
	} ->
	# File change: /etc/virtual/limit_unknown
	file { "/etc/virtual/limit_unknown":
		owner => mail,
		group => mail,
		mode => 644,
		ensure => present,
		content => 0,
		notify => Service['exim'],
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
	}
}