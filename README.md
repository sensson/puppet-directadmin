# directadmin

This module is used to configure DirectAdmin. It only supports RHEL based
servers at the moment such as RHEL itself and CentOS. There is currently no
support planned for other operating systems yet.

## Examples

### Installation and configuration

This will install DirectAdmin if it has not been installed yet. You will need
to specify the client and license id here. Keep in mind that when you enable
this module on an existing server, certain options may be overwritten.

If you don't specify an `interface` it will default to venet0:0 on OpenVZ containers
and eth0 on other systems. You can override this setting or not set it at all.

```
class { 'directadmin:'
	clientid => '1000',
	licenseid = '10000',
	interface = 'eth0',
}
```

If you want to change custombuild options before the installation runs you may
want to use the following class:

```
class { 'directadmin::custombuild::options': }
```

It supports a fair number of options. You can set the `php1_release` and `php1_mode`
with this class for example. A full list of options can be found in the file itself
and will be documented later.

When you make any changes to a setting in the custombuild options class it will 
automatically update the setting in /usr/local/directadmin/custombuild/options.conf but
it will not trigger a reinstallation of a particular feature in custombuild.

### Managing e-mail settings

DirectAdmin has a few features that relate to how e-mails are handled on the server. This
class has fairly basic support implemented for it. You can set an outgoing limit with
`mail_limit` and if you set `sa_updates` to true it will set a cron job that runs sa-update
on a daily basis.

```
class { 'directadmin::mail': mail_limit => 200, sa_updates => true, }
```

If you need to set custom rules for SpamAssassin you can do so with the following function:

```
directadmin::mail::spamassassin::score { 'URIBL_BLOCKED': score => 3, }
```

### Managing SSL

We have not explicitly enabled support for SSL in this module, though we find it useful to
be able to set SSL certificates for particular users. The following function allows you to do
this. Keep in mind though that `sslcert`, `sslkey` and `sslca` require a path. You need to put the
SSL certificate there yourself.

```
directadmin::user_ssl { 'domain.com': user => 'username', sslcert => '', sslkey => '', sslca => '' }
```

### ModSecurity

BETA WARNING: This is a beta implementation of mod security. We're still digging up bugs and 
although there are several cases where it does work, it is a known bug that DirectAdmin together
with mod_ruid2 and mod_security can cause a variety of issues, including redirect loops. 

Changing `modsecurity_version` will automatically update ModSecurity. It does not provide an
option to downgrade yet.

Be careful when using this function. 

```
class { 'directadmin::modsecurity': 'modsecurity_version => '2.8.0', 'secauditlogtype' => 'Concurrent', 'secauditlog' => '', 'secauditlogstoragedir' => '', 'secruleengine' => 'On' }
```

### Roles and profiles

In roles and profiles it sometimes helps to know when DirectAdmin is installed before trying
anything else. The installer is called directadmin-installer. You can use the following to chain
events if needed.

```
require => Exec['directadmin-installer'],
```
