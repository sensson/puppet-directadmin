# directadmin
class directadmin(
  $clientid               = undef,
  $licenseid              = undef,
  $interface              = undef,
  $auto_update            = false,
  $admin_password         = undef,
  $lan                    = false,
  $mail_limit             = $::directadmin::params::mail_limit,
  $mail_limit_per_address = $::directadmin::params::mail_limit_per_address,
  $sa_updates             = false,
  $php_imap               = false,
  $default_webmail        = $::directadmin::params::default_webmail,
  $default_rbl            = false,
  $installer_location     = $::directadmin::params::installer_location,
  $modsecurity            = $::directadmin::params::modsecurity,
  $modsecurity_ruleset    = $::directadmin::params::modsecurity_ruleset,
  $modsecurity_wordpress  = $::directadmin::params::modsecurity_wordpress,
) inherits directadmin::params {
  # Run some sanity checks
  if !is_numeric($directadmin::clientid) { fail("The client ID ${directadmin::clientid} is not a number.") }
  if !is_numeric($directadmin::licenseid) { fail("The license ID ${directadmin::licenseid} is not a number.") }

  class { '::directadmin::directories': } ->
  class { '::directadmin::custombuild': } ->
  class { '::directadmin::install': } ->
  class { '::directadmin::update': }
  class { '::directadmin::services': }
  class { '::directadmin::resources': }
  class { '::directadmin::mail': }
  class { '::directadmin::modsecurity': }

  # Set all required options for custombuild
  $custombuild_options = hiera('directadmin::custombuild::options', {})
  create_resources(directadmin::custombuild::set, $custombuild_options)

  # Set all required configuration settings
  $directadmin_config = hiera('directadmin::config::options', {})
  create_resources(directadmin::config::set, $directadmin_config)

  # Set up the chain that defines when to run which resources in order to support Hiera. This is done in two steps:
  # - The first chain doesn't include the directadmin_admin resouce on purpose, you may not use it.
  # - The second chain makes sure that should you include a different admin, it's running before the reseller package resource.
  # - The third and fourth chain make sure that our workaround for nameservers in directadmin::config::set works.
  Class['directadmin::services'] -> User <| title == 'admin' |> -> Directadmin_reseller_package <| |> -> Directadmin_reseller <| |> -> Directadmin_user_package <| |>
  User <| title == 'admin' |> -> Directadmin_admin <| |> -> Directadmin_reseller_package <| |>
  File_line <| path == '/usr/local/directadmin/data/users/admin/user.conf' |> -> Directadmin_reseller_package <| |>
  File_line <| path == '/usr/local/directadmin/data/users/admin/reseller.conf' |> -> Directadmin_reseller_package <| |>
}
