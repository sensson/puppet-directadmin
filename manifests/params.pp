# params
class directadmin::params {
  # The installation URL and a set of base packages that we need to install
  $installer_location             = 'http://www.directadmin.com/setup.sh'
  $custombuild_installer_location = 'http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz'

  # Mail settings
  $default_webmail        = 'roundcube'
  $mail_limit             = 200
  $mail_limit_per_address = 0

  # ModSecurity
  $modsecurity            = false
  $modsecurity_ruleset    = false
  $modsecurity_wordpress  = false
}