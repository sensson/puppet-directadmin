# directadmin

[![Build Status](https://travis-ci.org/sensson/puppet-directadmin.svg?branch=master)](https://travis-ci.org/sensson/puppet-directadmin) [![Puppet Forge](https://img.shields.io/puppetforge/v/sensson/directadmin.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/sensson/directadmin)

This module is used to configure DirectAdmin.

It can manage the installation of DirectAdmin, admin and reseller users and their 
packages. It is not meant to replace the API or other functionality from DirectAdmin
and we will never include support for managing users or other user based functions
such as managing databases and e-mail addresses. 

Pull requests and bug reports are always appreciated.

## Examples

### Installation and configuration

This will install DirectAdmin if it has not been installed yet. You will need
to specify the client and license id here. Keep in mind that when you enable
this module on an existing server, certain options may be overwritten.

If you don't specify an `interface` it will default to venet0:0 on OpenVZ containers
and eth0 on other systems. You can override this setting or not set it at all.

If you set `auto_update` to true it will attempt to update all packages that are
installed through Custombuild 2.0.

Set `lan` to true when using [DirectAdmin behind a NAT](http://www.directadmin.com/lan.shtml).

```
class { 'directadmin':
	clientid       => '1000',
	licenseid      => '10000',
	interface      => 'eth0',
	auto_update    => true,
	admin_password => 's0m3p4ssw0rd',
	lan            => false,
}
```

#### Configuration

This module allows you to configure DirectAdmin. We support all DirectAdmin 
configuration settings. Be careful though, we don't check if the settings are
actually valid. It will set it to whatever value you have specified.

```
directadmin::config::set { 'brute_force_log_scanner': value => '0', }
```

It also supports Hiera. If you want, you can specify a number of settings by simply
adding something similar to the following to your node's configuration files:

```
directadmin::config::options:
  brute_force_log_scanner:
    value: 0
  timeout:
    value: 30
  enable_ssl_sni:
    value: 1
```

If you want to run DirectAdmin behind a NAT you can use the `lan_ip` option and set
it to the internal IP address, for example:

```
lan_ip:
  value: 192.168.0.2
```

Changing a DirectAdmin configuration option will automatically trigger a reload of
the DirectAdmin service.

### Custombuild 2.0

Custombuild plays an important role in DirectAdmin's configurations and settings of
the software it uses to provide its services. Custombuild can be managed with this
module in a similar fashion as you would expect the command line to work. It is
automatically installed when you use this module.

We support all options Custombuild supports out of the box. There will never be any
addtional configuration required. If you want to change an option you can use the
following function:

```
directadmin::custombuild::set { 'php1_release': value => '5.5', }
```

It also supports Hiera. If you want, you can specify a number of settings by simply
adding something similar to the following to your node's configuration files:

```
directadmin::custombuild::options:
  php1_release: 
    value: '5.5'
  mysql: 
    value: '5.5'
  apache_ver: 
    value: '2.4'
  spamassassin:
    value: 'yes'
```    

All settings can be set before the installation runs.

When you make any changes to a setting in the custombuild options class it will 
automatically update the setting in /usr/local/directadmin/custombuild/options.conf but
it will not trigger a reinstallation of a particular feature in custombuild. If you do
want to do this, you can. For example by using something similar as the code below.

```
exec { 'rebuild-php':
	command => '/usr/local/directadmin/custombuild/build php n',
	subscribe => Directadmin::Custombuild::Set['php1_release'],
	require => Class['directadmin::install'],
	refreshonly => true,
}
```

### Managing services

We currently only support managing small portions of named. We have implemented two features:

* Managing also-notify, allow-transfer and notify settings
* Managing named rewrites (in case you are managing custom DNS templates)

You can enable `also-notify` and `allow-transfer` by passing the relevant parameters to this class.

```
class directadmin::services::named { also-notify => '1.2.3.4', allow-transfer => '1.2.3.4' }
```

Aside from that this module allows you to rewrite named, e.g. what's described here:
http://help.directadmin.com/item.php?id=141

You can do this with:

```
notify => Exec['rewrite-named-config'],
```

### Managing e-mail settings

DirectAdmin has a few features that relate to how e-mails are handled on the server. This
class has fairly basic support implemented for it. You can set an outgoing limit with
`mail_limit` and if you set `sa_updates` to true it will set a cron job that runs sa-update
on a daily basis. Setting `php_imap` to true will compile support for imap into PHP.

You can set the `default_webmail` client as well. This will change all the required settings for you
and defaults to Roundcube. If you set `default_rbl` to true it will create a symlink linking 
/etc/virtual/use_rbl_domains to /etc/virtual/domains. 

```
class { 'directadmin::mail':
    mail_limit => 200,
    sa_updates => true,
    php_imap => true,
    default_webmail => 'roundcube',
    default_rbl => false,
}
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
class { 'directadmin::modsecurity': modsecurity_version => '2.8.0', secauditlogtype => 'Concurrent', secauditlog => '/var/log/modsec_audit.log', secauditlogstoragedir => '', secruleengine => 'On' }
```

### Roles and profiles

In roles and profiles it sometimes helps to know when DirectAdmin is installed before trying
anything else. The installer is called directadmin-installer. You can use the following to chain
events if needed.

```
require => Exec['directadmin-installer'],
```

### Resources

DirectAdmin provides an API to automate certain actions. This module implements a few resources
to simplify the initial set up of a server with DirectAdmin. It's not going to replace the existing
web interface as it is simply not meant for that. Please keep in mind that this is a very basic
implementation of resources for Puppet, not all features are supported. They are considered helper
functions. They will add or remove resources only.

You may want to have a look at the DirectAdmin API docs to see what certain settings do or require. 
Resources will in most cases follow the directions in http://www.directadmin.com/api.html.

Every resource will have the following settings:

* `api_username` needs to be set to the user with access to the API.
* `api_password` is the password for the user mentioned before.
* `api_hostname` you need to change this if your API is not accessible on localhost.
* `api_port` if you run DirectAdmin on a different port than 2222 this allows you to change that.

NOTE: As the installer will not return a username or password to Puppet and we have not and will not
implement a feature that reads passwords from setup.txt for example, we recommend that you set up
a resource to manage the admin user before running any custom resources, e.g. just after the installer
has finished.

#### Set up a new admin user

It only manages the `email` and `password` property. Changing them will update the user.

```
directadmin_admin { "username":
	ensure			=> present,
	password		=> "password",
	email 			=> "your@email.address"
	notifications	=> "no",
	api_username 	=> "admin",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
	api_ssl			=> false (default),
}
```

#### Set up a new reseller package

You will need to set up a reseller package before you can create a reseller. All values
are manageable, as in, you can change them after a package has been created. Renaming
packages is not supported though.

```
directadmin_reseller_package { "newpackage2":
	ensure			=> present,		
	aftp			=> on,
	bandwidth		=> 1000,
	catchall		=> on,
	cgi				=> on,
	cron			=> on,
	dns				=> off/two/three,
	dnscontrol		=> on,
	domainptr		=> 2000,
	domains			=> 3000,
	ftp				=> 4000,
	inodes			=> 5000,
	ips				=> 1,
	login_keys		=> on,
	mysql			=> 6000,
	nemailf			=> 7000,
	nemails			=> 8000,
	nemailml		=> 9000,
	nemailr			=> 10000,
	nsubdomains		=> 11000,
	quota			=> 12000,
	php				=> on,
	spamassassin	=> on,
	ssl				=> on,
	ssh				=> on,
	userssh			=> on,
	oversell		=> on,
	sysinfo			=> on,
	serverip		=> on,		
	api_username 	=> "admin",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
	api_ssl			=> false (default),
}
```

#### Set up a new reseller

It only manages the `email` and `password` property. Changing them will update the user.

```
directadmin_reseller { "resellername":
	ensure 			=> present,
	password 		=> "password",
	email 			=> "your@email.address",
	domain 			=> "yourdomain.com",
	ip_address		=> "shared",
	user_package 	=> "an_existing_package",
	notifications	=> "no",
	api_username 	=> "admin",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
	api_ssl			=> false (default),
}
```

#### Set up a new user package

All values are manageable, as in, you can change them after a package has been created. 
Renaming packages is not supported though.

```
directadmin_user_package { "bronze":
	ensure			=> present,		
	aftp			=> off,
	bandwidth		=> 25000,
	catchall		=> on,
	cgi				=> on,
	cron			=> on,
	dnscontrol		=> on,
	domainptr		=> 1001,
	domains			=> 1,
	ftp				=> 2001,
	inodes			=> 3001,
	language		=> 'en',
	login_keys		=> on,
	mysql			=> 4001,
	nemailf			=> 5001,
	nemails			=> 6001,
	nemailml		=> 7001,
	nemailr			=> 8001,
	nsubdomains		=> unlimited,
	quota			=> 1000,
	php				=> on,
	spamassassin	=> on,
	ssl				=> on,
	sysinfo			=> on,
	suspend_at_limit => on,
	skin			=> 'enhanced',
	api_username 	=> "reseller",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
	api_ssl			=> false (default),
}
```
