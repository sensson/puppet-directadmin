# directadmin::custombuild
class directadmin::custombuild {
  $custombuild_installer = 'http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz'

  # File: set up the required directories, we need to ensure they exist
  file { [ '/usr/local/directadmin' ]:
    ensure => directory,
  } ->
  # Exec: download the latest custombuild version
  exec { 'install-custombuild':
    cwd     => '/usr/local/directadmin',
    command => "rm -rf custombuild* && wget --no-check-certificate -O custombuild.tar.gz ${custombuild_installer} && tar xvzf custombuild.tar.gz",
    creates => '/usr/local/directadmin/custombuild/options.conf',
    require => File['/usr/local/directadmin'],
  }
}