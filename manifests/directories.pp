# directadmin::directories
class directadmin::directories {
  # File: set up the required directories, we need to ensure they exist
  file { [ '/usr/local/directadmin', '/usr/local/directadmin/plugins' ]:
    ensure => directory,
    before => Class['directadmin::install'],
  }
}