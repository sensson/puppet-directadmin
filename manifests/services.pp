# directadmin::services
class directadmin::services {
  case $::operatingsystem {
    'RedHat', 'CentOS':   { $has_status = true }
    /^(Debian|Ubuntu)$/:  { $has_status = false }
    default:              { $has_status = true }
  }

  # Service: exim, our e-mail server
  service { 'exim':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => $has_status,
    require     => Exec['directadmin-installer'],
  }
  
  # Service: dovecot, our POP/IMAP server
  service { 'dovecot':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => $has_status,
    require     => Exec['directadmin-installer'],
  }
  
  # Service: apache, our web server
  service { 'httpd':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => $has_status,
    require     => Exec['directadmin-installer'],
  }
  
  # Service: directadmin, our control panel
  service { 'directadmin':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => $has_status,
    require     => Exec['directadmin-installer'],
  }

  # Service: named, our dns server
  service { 'named':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => $has_status,
    require     => Exec['directadmin-installer'],
  }
}