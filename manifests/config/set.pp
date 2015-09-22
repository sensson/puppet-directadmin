# directadmin::config::set
define directadmin::config::set($value = '') {
  if $value == '' { fail("Value can't be empty.") }
  
  # File_line: set a config setting in DirectAdmin and notify the service.
  file_line { "config-set-${title}-${value}":
    path  => '/usr/local/directadmin/conf/directadmin.conf',
    line  => "${title}=${value}",
    match => "^${title}=",
    require => Class['directadmin::install'],
    notify  => Service['directadmin'],
  }

  # Special settings: nameservers workaround for the 'admin' user.
  # - This makes sure that new resellers will get the right values.
  if $title =~ /^ns\d+/ {
    # File_line: set a nameserver value in admin/user.conf
    file_line { "config-set-admin-user-${title}-${value}":
      path  => '/usr/local/directadmin/data/users/admin/user.conf',
      line  => "${title}=${value}",
      match => "^${title}=",
      require => Class['directadmin::install'],
    }

    # File_line: set a nameserver value in admin/reseller.conf
    file_line { "config-set-admin-reseller-${title}-${value}":
      path  => '/usr/local/directadmin/data/users/admin/reseller.conf',
      line  => "${title}=${value}",
      match => "^${title}=",
      require => Class['directadmin::install'],
    }
  }
}
