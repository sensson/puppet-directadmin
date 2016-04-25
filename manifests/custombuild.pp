# directadmin::custombuild
class directadmin::custombuild {
  $custombuild_installer = 'http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz'

  # Exec: download the latest custombuild version
  exec { 'install-custombuild':
    cwd     => '/usr/local/directadmin',
    command => "rm -rf custombuild* && wget --no-check-certificate -O custombuild.tar.gz ${custombuild_installer} && tar xvzf custombuild.tar.gz",
    creates => '/usr/local/directadmin/custombuild/options.conf',
    require => File['/usr/local/directadmin'],
    path    => '/bin:/usr/bin',
  }
}
