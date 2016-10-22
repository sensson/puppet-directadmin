# directadmin::user_ssl
define directadmin::user_ssl($domain = $title, $user = '', $sslcert = '', $sslkey = '', $sslca = '') {
  # This is our certificate
  file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.cert":
    content => template($sslcert),
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
  }

  # Our CA
  file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.cacert":
    content => template($sslca),
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
  }

  # Our key
  file { "/usr/local/directadmin/data/users/${user}/domains/${domain}.key":
    content => template($sslkey),
    notify  => Service['httpd'],
    require => Exec['directadmin-installer'],
  }
}