# directadmin::install
class directadmin::install inherits directadmin {
  # Decide which interface to use
  if $directadmin::interface == undef {
    if has_interface_with('venet0') { $directadmin_interface = 'venet0:0' }
    else { $directadmin_interface = 'eth0'}
  } else {
    $directadmin_interface = $directadmin::interface
  }

  # The following will install all required packages for SpamAssassin on CentOS servers.
  if $::osfamily == 'RedHat' {
    if versioncmp($::operatingsystemmajrelease, '6') >= 0 {
      $directadmin_packages = [
            'perl-ExtUtils-MakeMaker', 'perl-Digest-SHA', 'perl-Net-DNS', 'perl-NetAddr-IP',
            'perl-Archive-Tar', 'perl-IO-Zlib', 'perl-Mail-SPF', 'perl-IO-Socket-INET6',
            'perl-IO-Socket-SSL', 'perl-Mail-DKIM', 'perl-DBI', 'perl-Encode-Detect',
            'perl-HTML-Parser', 'perl-HTML-Tagset', 'perl-Time-HiRes', 'perl-libwww-perl',
            'perl-ExtUtils-Embed',
          ]
    }
    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
      $additional_packages = [
          'perl-Sys-Syslog', 'perl-DB_File',
        ]

      # Package: required packages for SpamAssassin on CentOS 7+
      package { $additional_packages:
          ensure => installed,
          before => Exec['directadmin-download-installer'],
      }
    }
  }

  # The following will install all required packages for SpamAssassin on Debian servers.
  if $::osfamily == 'Debian' {
    $directadmin_packages = [
        'libarchive-any-perl', 'libhtml-parser-perl', 'libnet-dns-perl', 'libnetaddr-ip-perl',
        'libhttp-date-perl',
      ]
  }

  # Package: required packages for SpamAssassin etc.
  package { $directadmin_packages:
    ensure => installed,
    before => Exec['directadmin-download-installer'],
  }

  # Using DirectAdmin on a server behind NAT (example: 192.168.0.x)? Touch /root/.lan.
  # When this file contains '1', setup.sh will skip --bind-address in wget.
  # For more information about running DirectAdmin behind NAT: http://www.directadmin.com/lan.shtml
  if $directadmin::lan {
    file { '/root/.lan':
      ensure  => file,
      content => '1',
      before  => Exec['directadmin-installer'],
    }
  }

  # Exec: make sure the required packages are installed automatically. This provides support for all operating systems.
  exec { 'directadmin-set-pre-install':
    cwd     => '/root',
    command => 'echo 1 > /root/.preinstall',
    creates => '/root/.preinstall',
    before  => Exec['directadmin-installer'],
    path    => '/bin:/usr/bin',
  }

  # Exec: set up the installation files
  exec { 'directadmin-download-installer':
    cwd     => '/root',
    command => "wget -O setup.sh --no-check-certificate ${::directadmin::installer_location} && chmod +x /root/setup.sh",
    creates => '/root/setup.sh',
    path    => '/bin:/usr/bin',
  }

  # Exec: install DirectAdmin
  exec { 'directadmin-installer':
    cwd     => '/root',
    command => "echo 2.0 > /root/.custombuild && /root/setup.sh ${::directadmin::clientid} ${::directadmin::licenseid} ${::fqdn} ${directadmin_interface}",
    require => [ Exec['directadmin-download-installer'], Class['directadmin::custombuild'], ],
    creates => '/usr/local/directadmin/conf/directadmin.conf',
    timeout => 0,
    path    => '/sbin:/usr/sbin:/bin:/usr/bin',
  }
}
