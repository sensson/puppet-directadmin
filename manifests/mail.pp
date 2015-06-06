# directadmin::mail
class directadmin::mail(
  $mail_limit = 200,
  $sa_updates = true,
  $php_imap = false,
  $default_webmail = 'roundcube',
) {
  # File change: set up our e-mail limit
  file { '/etc/virtual/limit':
    ensure  => present,
    owner   => mail,
    group   => mail,
    mode    => '0644',

    # maximum e-mails per day, it needs quotes to ensure it gets 
    # read correctly, Hiera will set as an integer for example
    content => "${mail_limit}",

    # restart on change
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  } ->
  # File change: /etc/virtual/limit_unknown
  file { '/etc/virtual/limit_unknown':
    ensure  => present,
    owner   => mail,
    group   => mail,
    mode    => '0644',
    content => 0,
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  }

  # File: set the default webmail client
  file { '/var/www/html/webmail':
    ensure => link,
    target => "/var/www/html/${default_webmail}",
    require => Exec['directadmin-installer'],
  }
  # File_line: set the default /webmail alias
  file_line { 'httpd-alias-default-webmail':
    ensure => present,
    path => '/etc/httpd/conf/extra/httpd-alias.conf',
    line => "Alias /webmail /var/www/html/${default_webmail}",
    match => 'Alias \/webmail',
    notify => Service['httpd'],
    require => Exec['directadmin-installer'],
  }
  directadmin::config::set { 'webmail_link': value => $default_webmail, }

  # Install support for imap in php if required
  if $php_imap == true {
    exec { 'directadmin-download-php-imap':
      cwd     => '/root',
      command => 'wget -O /root/imap_php.sh files.directadmin.com/services/all/imap_php.sh && chmod +x /root/imap_php.sh',
      creates => '/root/imap_php.sh',
      require => Exec['directadmin-installer'],
    } ->
    exec { 'directadmin-install-php-imap':
      cwd     => '/root',
      command => '/root/imap_php.sh',
      unless  => 'php -i | grep imap | wc -l | grep -c 3',
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
    ensure  => $sa_cron,
    command => '/usr/bin/sa-update; /sbin/service exim restart',
    user    => root,
    hour    => 7,
    minute  => 5,
    require => Exec['directadmin-installer'],
  }
}
