# directadmin::config::set
define directadmin::config::set($value = '') {
  if $value == '' { fail("Value can't be empty.") }
  
  # File_line: set a config setting in DirectAdmin and notify the service.
  file_line { "config-set-${title}-${value}":
    path  => '/usr/local/directadmin/conf/directadmin.conf',
    line  => "${title}=${value}",
    match => "${title}\=",
    require => Class['directadmin::install'],
    notify  => Service['directadmin'],
  }
}