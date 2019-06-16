# directadmin::user_ssl
define directadmin::user_ssl($domain = $title, $user = '', $sslcert = '', $sslkey = '', $sslca = '', $sslpem = '') {
  if $user == '' { fail("user can't be empty") }
  if $sslcert == '' { fail("sslcert can't be empty") }
  if $sslkey == '' { fail("sslkey can't be empty") }

  # This is our certificate
  file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.cert":
    content => $sslcert,
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
  }

  # Our key
  file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.key":
    content => $sslkey,
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
    owner   => 'diradmin',
    group   => 'mail',
  }

  if $sslca != '' {
    # Our CA
    file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.cacert":
      content => $sslca,
      notify  => Service['httpd'],
      require => Exec['directadmin-installer'],
    }
  }

  if $sslpem != '' {
    # A PEM file to be used by SNI (e.g. Exim)
    file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.cert.combined":
      content => $sslpem,
      notify  => Service['httpd'],
      require => Exec['directadmin-installer'],
      owner   => 'diradmin',
      group   => 'mail',
    }
  }
}
