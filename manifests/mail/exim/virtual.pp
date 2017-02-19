# directadmin::mail::exim::virtual
define directadmin::mail::exim::virtual(
  $value = undef,
  $file  = undef,
) {
  # Check the $file parameter
  if $file == undef { fail('file must be set.') }
  if $file =~ /\/etc\/virtual/ { fail('file should be specified without /etc/virtual/') }

  # Check $value parameter - we don't do consistency checks!
  if $value == undef { fail('value must be set.') }

  # Manage /etc/virtual/${file}
  ensure_resource('file', "/etc/virtual/${file}", { 'ensure' => 'present', 'mode' => '0644'} )

  file_line { "exim-set-${file}-${value}":
    path    => "/etc/virtual/${file}",
    line    => $value,
    require => File["/etc/virtual/${file}"],
    notify  => Service['exim'],
  }
}