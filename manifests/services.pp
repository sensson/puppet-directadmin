# directadmin::services
class directadmin::services {
  $exim = lookup({ 'name' => 'directadmin::services:exim', 'default_value' => true })
  $dovecot = lookup({ 'name' => 'directadmin::services:dovecot', 'default_value' => true })
  $named = lookup({ 'name' => 'directadmin::services:named', 'default_value' => true })

  case $::operatingsystem {
    'RedHat', 'CentOS':   { $has_status = true }
    /^(Debian|Ubuntu)$/:  { $has_status = false }
    default:              { $has_status = true }
  }

  if $exim {
    # Service: exim, our e-mail server
    service { 'exim':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => $has_status,
      require    => Exec['directadmin-installer'],
    }
  }

  if $dovecot {
    # Service: dovecot, our POP/IMAP server
    service { 'dovecot':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => $has_status,
      require    => Exec['directadmin-installer'],
    }
  }

  # Service: apache, our web server
  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => $has_status,
    require    => Exec['directadmin-installer'],
  }

  # Service: directadmin, our control panel
  service { 'directadmin':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => $has_status,
    require    => Exec['directadmin-installer'],
  }

  if $named {
    # Service: named, our dns server
    service { 'named':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => $has_status,
      require    => Exec['directadmin-installer'],
    }
  }

  # Service: mysqld, our database server
  service { 'mysqld':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => $has_status,
    require    => Exec['directadmin-installer'],
  }
}
