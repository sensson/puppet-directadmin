# This function sets custombuild settings.
# More information on all the available options:
# ./build opt_help full
define directadmin::custombuild::set($value = '') {
  if $value == '' { fail("Value can't be empty.") }
  
  # Exec: ./build set setting value, this sets a configuration setting in custombuild
  # It needs to run before the installation so we can pre-set things before it runs.
  exec { "custombuild-set-${title}-${value}":
    command => "/usr/local/directadmin/custombuild/build set ${title} ${value}",
    unless => "grep /usr/local/directadmin/custombuild/options.conf -e '${title}=${value}'",
    require => Class['directadmin::custombuild'],
    before => Class['directadmin::install'],
    path => '/bin:/usr/bin',
  }
}
