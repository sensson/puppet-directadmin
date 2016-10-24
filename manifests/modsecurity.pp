# directadmin::mod_security
class directadmin::modsecurity inherits directadmin {
  if $::directadmin::modsecurity {
    directadmin::config::set { 'modsecurity': value => 'yes' }

    # This enables the modsecurity ruleset from DirectAdmin
    if $::directadmin::modsecurity_ruleset {
      directadmin::config::set { 'modsecurity_ruleset': value => 'yes' }
    }

    # This enables our custom wordpress ruleset
    if $::directadmin::modsecurity_wordpress {
      file { [ '/usr/local/directadmin/custombuild/custom/modsecurity/', '/usr/local/directadmin/custombuild/custom/modsecurity/conf/' ]:
        ensure  => directory,
        require => File['/usr/local/directadmin/custombuild/custom/'],
      } ->
      file { '/usr/local/directadmin/custombuild/custom/modsecurity/conf/wordpress.conf':
        ensure  => present,
        content => template('directadmin/modsecurity/modsec-wordpress.conf.erb'),
      }
    }
  }
}
