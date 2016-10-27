# directadmin::mail
class directadmin::mail {
  # File change: set up our e-mail limit
  file { '/etc/virtual/limit':
    ensure  => present,
    owner   => mail,
    group   => mail,
    mode    => '0644',

    # maximum e-mails per day, it needs quotes to ensure it gets
    # read correctly, Hiera will set it as an integer for example
    content => sprintf('%s', $::directadmin::mail_limit),

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
    content => sprintf('%s', '0'),
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  } ->
  # File change: /etc/virtual/user_limit
  file { '/etc/virtual/user_limit':
    ensure  => present,
    owner   => mail,
    group   => mail,

    # this file is set to 755 by directadmin by default
    mode    => '0755',

    # maximum e-mails per day, per e-mail address.
    # it needs quotes to ensure it gets read correctly, Hiera will 
    # set it as an integer for example
    content => sprintf('%s', $::directadmin::mail_limit_per_address),
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  }

  # File: set the default webmail client
  file { '/var/www/html/webmail':
    ensure  => link,
    target  => "/var/www/html/${::directadmin::default_webmail}",
    require => Exec['directadmin-installer'],
  }
  # File_line: set the default /webmail alias
  file_line { 'httpd-alias-default-webmail':
    ensure  => present,
    path    => '/etc/httpd/conf/extra/httpd-alias.conf',
    line    => "Alias /webmail /var/www/html/${::directadmin::default_webmail}",
    match   => 'Alias \/webmail',
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
  }
  directadmin::config::set { 'webmail_link': value => $::directadmin::default_webmail, }

  # Install support for imap in php if required
  if $::directadmin::php_imap == true {
    # Make sure libc-client2007e-dev is installed on Debian and Ubuntu
    if $::operatingsystem =~ /^(Debian|Ubuntu)$/ {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        if versioncmp($::puppetversion, '3.6.0') >= 0 {
            # There is a really weird bug in puppet-lint that errors out when
            # a space is added between Package and {.
            Package{
                allow_virtual => true,
            }
        }

        package { 'libc-client2007e-dev':
          ensure => installed,
          before => Exec['directadmin-download-php-imap'],
        }
      }
    }
    exec { 'directadmin-download-php-imap':
      cwd     => '/root',
      command => 'wget -O /root/imap_php.sh files.directadmin.com/services/all/imap_php.sh && chmod +x /root/imap_php.sh',
      creates => '/root/imap_php.sh',
      require => Exec['directadmin-installer'],
      path    => '/bin:/usr/bin',
    } ->
    exec { 'directadmin-install-php-imap':
      cwd     => '/root',
      command => '/root/imap_php.sh',
      unless  => 'php -i | grep -i c-client | wc -l | grep -c 1',
      require => Exec['directadmin-installer'],
      timeout => 0,
      path    => '/bin:/usr/bin',
      notify  => Service['httpd'],
    }
  }

  # File_line: make sure the primary hostname is set in exim.conf
  # as we have seen some issues with CentOS 7 here.
  file_line { 'exim-set-primary-hostname':
    path    => '/etc/exim.conf',
    line    => "primary_hostname = ${::fqdn}",
    match   => '^(# )?primary_hostname =',
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  }

  # SpamAssassin cron jobs
  if $::directadmin::sa_updates == true {
    $sa_cron = 'present'
  } else {
    $sa_cron = 'absent'
  }

  # Cron: daily update of SpamAssassin rules
  cron { 'exim-sa-update':
    ensure  => $sa_cron,
    command => '/usr/bin/sa-update && /sbin/service exim restart >/dev/null 2>&1',
    user    => root,
    hour    => 7,
    minute  => 5,
    require => Exec['directadmin-installer'],
  }

  # Set up RBL checks by default
  if $::directadmin::default_rbl == true {
    file { '/etc/virtual/use_rbl_domains':
      ensure => 'link',
      target => '/etc/virtual/domains',
    }
  }
}
