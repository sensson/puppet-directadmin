# params
class directadmin::params {
  # The installation URL and a set of base packages that we need to install
  $installer_location     = 'http://www.directadmin.com/setup.sh'

  # Mail settings
  $default_webmail        = 'roundcube'
  $mail_limit             = 200
  $mail_limit_per_address = 0
}