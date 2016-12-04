# directadmin::mail::exim::config
define directadmin::mail::exim::config(
  $value = undef,
  $file  = undef,
) {
  # Check the $file parameter
  if $file == undef { fail('file must be set.') }
  if $file =~ /\/etc/ { fail('file should be specified without /etc') }

  # Check $value parameter - we don't do consistency checks!
  if $value == undef { fail('value must be set.') }

  # Manage /etc/${file}
  ensure_resource('file', "/etc/${file}", { 'ensure' => 'present', 'mode' => '0644'} )

  file_line { "exim-set-${file}-${title}-${value}":
    path    => "/etc/${file}",
    line    => "${title}==${value}",
    match   => "^${title}==",
    require => File["/etc/${file}"],
    notify  => Service['exim'],
  }
}
