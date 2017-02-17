# directadmin

[![Build Status](https://travis-ci.org/sensson/puppet-directadmin.svg?branch=master)](https://travis-ci.org/sensson/puppet-directadmin) [![Puppet Forge](https://img.shields.io/puppetforge/v/sensson/directadmin.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/sensson/directadmin)

This module is used to configure DirectAdmin.

It can manage the installation of DirectAdmin, admin and reseller users and their 
packages. It is not meant to replace the API or other functionality from DirectAdmin.

Pull requests and bug reports are always appreciated.

## Examples

### Installation and configuration

This will install DirectAdmin if it has not been installed yet. You will need
to specify the client and license id here. Keep in mind that when you enable
this module on an existing server, certain options may be overwritten.

If you don't specify an `interface` it will default to venet0:0 on OpenVZ containers
and eth0 on other systems. You can override this setting or not set it at all.

Set `lan` to true when using [DirectAdmin behind a NAT](http://www.directadmin.com/lan.shtml).

```
class { 'directadmin':
    clientid       => '1000',
    licenseid      => '10000',
    interface      => 'eth0',
    admin_password => '$1$xyz$4SuXM/NcNyHdr1j2DppL5/',
    lan            => false,
}
```

## Reference

### Parameters

#### directadmin

We provide a number of configuration options to change particular settings
or to override our defaults when required.

##### `clientid`

This is the client id for your DirectAdmin license. Required. Defaults to undef.

##### `licenseid`

This is the licence id for your DirectAdmin license. Required. Defaults to undef.

##### `interface`

Change the interface for your license. Defaults to eth0 or venet0:0 on OpenVZ.

##### `auto_update`

Set this to true if you want Puppet to check for custombuild updates. Defaults to false.

##### `admin_password`

Manage the admin user password. Recommended if you want to manage admin users, reseller
packages and resellers. This needs to be a hash. Defaults to undef.

##### `lan`

Set `lan` to true when using [DirectAdmin behind a NAT](http://www.directadmin.com/lan.shtml).

##### `mail_limit`

Set a maximum outgoing mail limit per user account. Defaults to 200.

##### `mail_limit_per_address`

Set a maximum outgoing mail limit per e-mail address. Defaults to 0 (no limit).

##### `sa_updates`

Set this to true if you want to enable daily SpamAssassin updates. Defaults to false.

##### `php_imap`

Set this to true if you want to enable the imap extension in PHP. Defaults to false.

##### `default_webmail`

Set the default webmail client. Defaults to roundcube.

##### `default_rbl`

This creates a symlink that makes sure all e-mail domains are checked agains the RBL's
in Exim. Defaults to false.

##### `installer_location`

Override the DirectAdmin installer location. Defaults to http://www.directadmin.com/setup.sh.

##### `modsecurity`

Enable ModSecurity. Defaults to false.

##### `modsecurity_ruleset`

Enable a ModSecurity ruleset. Valid options comodo/owasp/false. Defaults to false.

##### `modsecurity_wordpress`

Enable a WordPress brute force prevention ruleset. Defaults to false.

#### directadmin::services::named

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

##### `allow_transfer`

Set up an IP address to allow zone transfers. Defaults to ''.

##### `also_notify`

Also notify this IP address when zone changes occur. Defaults to ''.

##### `ensure_transfer`

Make sure this configuration exists or not. Defaults to 'present'.

##### `ensure_notify`

Make sure this configuration exists or not. Defaults to 'present.'

### Defines

#### directadmin::config::set

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

##### `value`

Set the value of the configuration item you want to change. Defaults to ''

#### directadmin::custombuild::set

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
    command     => '/usr/local/directadmin/custombuild/build php n',
    subscribe   => Directadmin::Custombuild::Set['php1_release'],
    require     => Class['directadmin::install'],
    refreshonly => true,
}
```

##### `value`

Set the value of the configuration item you want to change. Defaults to ''

#### directadmin::mail::spamassassin::score

If you need to set custom rules for SpamAssassin you can do so with the following function:

```
directadmin::mail::spamassassin::score { 'URIBL_BLOCKED': score => 3, }
```

##### `score`

Set the score for a specific SpamAssassin check. Defaults to 1.

#### directadmin::mail::spamassassin::config

This allows you to create larger configuration files with specific settings. These configuration
files will be created in /etc/mail/spamassassin. It is possible to specify a prefix with the
`order` parameter as SpamAssassin reads these files in alphabetical order.

The filename will be `$order-$title.cf` and cannot be changed.

##### `ensure`

Valid values: present, absent. Defaults to 'present'.

##### `content`

Set the content of the configuration file. Defaults to ''.

##### `order`

Set the order in which the files should be read. Numeric values are recommended. Defaults to '99'.

#### directadmin::mail::exim::config

This allows you to set override custom configurations such as in exim.strings.conf.custom. It takes
title as its setting. It will automatically notify Exim to reload.

##### `file`

Valid values are e.g. 'exim.strings.conf.custom'. Do not specify a path. Defaults to 'undef'.

##### `value`

Set the value for the setting you're changing. Defaults to 'undef'.

#### directadmin::mail::exim::virtual

This allows you to set values in /etc/virtual. You can manage 'skip_rbl_hosts_ip' for example.

##### `file`

Valid values are e.g. 'skip_rbl_hosts_ip'. Do not specify a path. Defaults to 'undef'.

##### `value`

Set the value. Defaults to 'undef'.

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
    ensure        => present,
    password      => "password",
    email         => "your@email.address"
    notifications => "no",
    api_username  => "admin",
    api_password  => "api_password",
    api_hostname  => "localhost (default)",
    api_port      => "2222 (default)",
    api_ssl       => false (default),
}
```

#### Set up a new reseller package

You will need to set up a reseller package before you can create a reseller. All values
are manageable, as in, you can change them after a package has been created. Renaming
packages is not supported though.

```
directadmin_reseller_package { "newpackage2":
    ensure       => present,
    aftp         => on,
    bandwidth    => 1000,
    catchall     => on,
    cgi          => on,
    cron         => on,
    dns          => off/two/three,
    dnscontrol   => on,
    domainptr    => 2000,
    domains      => 3000,
    ftp          => 4000,
    inodes       => 5000,
    ips          => 1,
    login_keys   => on,
    mysql        => 6000,
    nemailf      => 7000,
    nemails      => 8000,
    nemailml     => 9000,
    nemailr      => 10000,
    nsubdomains  => 11000,
    quota        => 12000,
    php          => on,
    spamassassin => on,
    ssl          => on,
    ssh          => on,
    userssh      => on,
    oversell     => on,
    sysinfo      => on,
    serverip     => on,
    api_username => "admin",
    api_password => "api_password",
    api_hostname => "localhost (default)",
    api_port     => "2222 (default)",
    api_ssl      => false (default),
}
```

#### Set up a new reseller

It only manages the `email` and `password` property. Changing them will update the user.

```
directadmin_reseller { "resellername":
    ensure        => present,
    password      => "password",
    email         => "your@email.address",
    domain        => "yourdomain.com",
    ip_address    => "shared",
    user_package  => "an_existing_package",
    notifications => "no",
    api_username  => "admin",
    api_password  => "api_password",
    api_hostname  => "localhost (default)",
    api_port      => "2222 (default)",
    api_ssl       => false (default),
}
```

#### Set up a new user package

All values are manageable, as in, you can change them after a package has been created. 
Renaming packages is not supported though.

```
directadmin_user_package { "bronze":
    ensure           => present,
    aftp             => off,
    bandwidth        => 25000,
    catchall         => on,
    cgi              => on,
    cron             => on,
    dnscontrol       => on,
    domainptr        => 1001,
    domains          => 1,
    ftp              => 2001,
    inodes           => 3001,
    language         => 'en',
    login_keys       => on,
    mysql            => 4001,
    nemailf          => 5001,
    nemails          => 6001,
    nemailml         => 7001,
    nemailr          => 8001,
    nsubdomains      => unlimited,
    quota            => 1000,
    php              => on,
    spamassassin     => on,
    ssl              => on,
    sysinfo          => on,
    suspend_at_limit => on,
    skin             => 'enhanced',
    api_username     => "reseller",
    api_password     => "api_password",
    api_hostname     => "localhost (default)",
    api_port         => "2222 (default)",
    api_ssl          => false (default),
}
```

## Limitations

This module has been tested on:

* CentOS 6
* CentOS 7
* Debian 7

## Development

We strongly believe in the power of open source. This module is our way
of saying thanks.

This module is tested against the Ruby versions from Puppet's support
matrix. Please make sure you have a supported version of Ruby installed.

If you want to contribute please:

1. Fork the repository.
2. Run tests. It's always good to know that you can start with a clean slate.
3. Add a test for your change.
4. Make sure it passes.
5. Push to your fork and submit a pull request.

We can only accept pull requests with passing tests.

To install all of its dependencies please run:

```
bundle install --path vendor/bundle --without development
```

### Running unit tests

```
bundle exec rake test
```

### Running acceptance tests

The unit tests only verify if the code runs, not if it does exactly
what we want on a real machine. For this we use Beaker. Beaker will
start a new virtual machine (using Vagrant) and runs a series of
simple tests.

Beaker is currently not supported due to licensing constraints.
