# directadmin::named
class directadmin::services::named(
  $allow_transfer = '',
  $also_notify = '',
  $ensure_transfer = 'present',
  $ensure_notify = 'present',
) {
  # Exec: rewrite named configurations when required
  exec { 'rewrite-named-config':
    command => 'echo "action=rewrite&value=named" >> /usr/local/directadmin/data/task.queue',
    require => Exec['directadmin-installer'],
    refreshonly => true,
    unless => 'grep -c named /usr/local/directadmin/data/task.queue',
  }
  
  if $allow_transfer != '' {
    # File_line: enable allow transfers
    file_line { 'named-enable-allow-transfer':
      ensure => $ensure_transfer,
      path => '/etc/named.conf',
      line => "\tallow-transfer { ${allow_transfer}; };",
      match => "^\tallow-transfer",
      after => '^options {',
      notify => Service['named'],
      require => Exec['directadmin-installer'],
    }
  }
  
  if $also_notify != '' {
    # File_line: also notify  
    file_line { 'named-enable-also-notify':
      ensure => $ensure_notify,
      path => '/etc/named.conf',
      line => "\talso-notify { ${also_notify}; };",
      match => "^\talso-notify",
      after => '^options {',
      notify => Service['named'],
      require => Exec['directadmin-installer'],
    }

    # File_line: also notify
    file_line { 'named-enable-notify-setting':
      ensure => $ensure_notify,
      path => '/etc/named.conf',
      line => "\tnotify yes;",
      match => "^\tnotify",
      after => '^options {',
      notify => Service['named'],
      require => Exec['directadmin-installer'],
    }
  }
}