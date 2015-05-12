# directadmin::mail::spamassassin::score
define directadmin::mail::spamassassin::score($score = 1) {
  file_line { "enable-${title}-${score}":
    ensure  => present,
    path    => '/etc/mail/spamassassin/local.cf',
    line    => "score ${title} ${score}",
    match   => "^score ${title}.*",
    notify  => Service['exim'],
    require => Exec['directadmin-installer'],
  }
}