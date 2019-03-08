# directadmin::mod_security
class directadmin::modsecurity inherits directadmin {
  if $::directadmin::modsecurity {
    directadmin::custombuild::set { 'modsecurity': value => 'yes' }

    # This enables the modsecurity ruleset from DirectAdmin, it's disabled by us by default
    if $::directadmin::modsecurity_ruleset {
      directadmin::custombuild::set { 'modsecurity_ruleset': value => $::directadmin::modsecurity_ruleset }
    } else {
      directadmin::custombuild::set { 'modsecurity_ruleset': value => 'no' }
    }

    # This enables our custom wordpress ruleset
    if $::directadmin::modsecurity_wordpress {
      file { [ '/usr/local/directadmin/custombuild/custom/modsecurity/', '/usr/local/directadmin/custombuild/custom/modsecurity/conf/' ]:
        ensure  => directory,
        require => File['/usr/local/directadmin/custombuild/custom/'],
        before  => File['/usr/local/directadmin/custombuild/custom/modsecurity/conf/wordpress.conf'],
      }
      file { '/usr/local/directadmin/custombuild/custom/modsecurity/conf/wordpress.conf':
        ensure  => present,
        content => template('directadmin/modsecurity/modsec-wordpress.conf.erb'),
      }
    }
  }
}
