# directadmin::mail::spamassassin::config
# Use this if you want to create bigger configuration blocks
define directadmin::mail::spamassassin::config(
  $ensure = 'present',
  $content = '',
  $order = 99,
) {
  file { "${order}-${title}":
    ensure  => $ensure,
    path    => "/etc/mail/spamassassin/${order}-${title}.cf",
    content => $content,
    require => Exec['directadmin-installer'],
    notify  => Service['exim'],
  }
}