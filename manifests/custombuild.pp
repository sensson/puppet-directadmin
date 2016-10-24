# directadmin::custombuild
class directadmin::custombuild inherits directadmin {
  # Exec: download the latest custombuild version
  exec { 'install-custombuild':
    cwd     => '/usr/local/directadmin',
    command => "rm -rf custombuild* && wget --no-check-certificate -O custombuild.tar.gz ${::directadmin::params::custombuild_installer_location} && tar xvzf custombuild.tar.gz",
    creates => '/usr/local/directadmin/custombuild/options.conf',
    require => File['/usr/local/directadmin'],
    path    => '/bin:/usr/bin',
  }
}
