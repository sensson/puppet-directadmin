# directadmin

This module is used to configure DirectAdmin. It only supports RHEL based
servers at the moment such as RHEL itself and CentOS. 

The module itself is modular too and we assume that you don't want to enable
everything from the start. You will need to be specific as to what you want
to enable and what not.

## Examples

```
class { 'directadmin:' }
```

This initializes DirectAdmin's services and installs some required
packages that we believe are necessary.  

```
class { 'directadmin::mail': mail_limit => 200, sa_updates => true, }
```

This will only manage the mail limit for Exim and with sa_updates you can
manage a cron job that will run sa-update on a daily basis for you.

```
directadmin::mail::spamassassin::score { 'URIBL_BLOCKED': score => 3, }
```

This can be used to set up custom spamassassin scores if required. 

```
class { 'directadmin::custombuild::options': }
```

Custombuild has a lot of options implemented and can be used to manage
the options.conf file of DirectAdmin. It doesn't rebuild PHP after you've made
a change due to the issues that may come up during a rebuild.

```
directadmin::user_ssl { 'domain.com': user => 'username', sslcert => '', sslkey => '', sslca => '' }
```

This can be used to manage SSL certificates for users. 

```
class { 'directadmin::modsecurity': 'modsecurity_version => '2.8.0', 'secauditlogtype' => 'Concurrent', 'secauditlog' => '', 'secauditlogstoragedir' => '', 'secruleengine' => 'On' }
```

BETA: This sets up mod_security on DirectAdmin servers.
