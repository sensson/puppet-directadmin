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
direactadmin_admin { "username":
	ensure			=> present,
	password		=> "password",
	email 			=> "your@email.address"
	notifications	=> "no",
	api_username 	=> "admin",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
}
```

#### Set up a new reseller package

You will need to set up a reseller package before you can create a reseller. All values
are manageable, as in, you can change them after a package has been created. Renaming
packages is not supported though.

directadmin_reseller_package { "newpackage2":
	ensure			=> present,		
	aftp			=> on,
	bandwidth		=> 1000,
	catchall		=> on,
	cgi				=> on,
	cron			=> on,
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
}

#### Set up a new reseller

It only manages the `email` and `password` property. Changing them will update the user.

```
directadmin_reseller { "resellername":
	ensure 			=> present,
	password 		=> "password",
	email 			=> "your@email.address"
	domain 			=> "yourdomain.com",
	ip_address		=> "shared",
	user_package 	=> "an_existing_package",
	notifications	=> "no",
	api_username 	=> "admin",
	api_password 	=> "api_password",
	api_hostname	=> "localhost (default)",
	api_port		=> "2222 (default)",
}
```
