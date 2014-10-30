# Set custom spamassassin scores. It uses $title as item and $score as value.
# directadmin::mail::spamassassin::score { 'URIBL_BLOCKED': score => 3, }

define directadmin::mail::spamassassin::score($score = 1) {
	file_line { "enable-$title-$score":
		path 	=> "/etc/mail/spamassassin/local.cf",
		line 	=> "score $title $score",
		match	=> "^score $title.*",
		ensure 	=> present,
		notify 	=> Service['exim'],
	}
}