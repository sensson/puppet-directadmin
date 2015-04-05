Puppet::Type.newtype(:directadmin_user_package) do
  @doc = "Manage DirectAdmin packages for users."
  
  ensurable
  
  # The following parameters are required.
  validate do    
    fail('api_username parameter is required.') if self[:api_username].nil?
    fail('api_password parameter is required.') if self[:api_password].nil?
    
    # Additional verification.
  end
  
  newparam(:package_name, :namevar => true) do
    desc 'The package\'s name.'
    validate do |value|
        raise Puppet::Error, "package_name is #{value.length} characters long; must be of length 4 or greater" if value.length < 4
    end
  end
  
  newproperty(:aftp) do
    desc 'Allow anonymous FTP access.'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:bandwidth) do
    desc 'Bandwidth limit in MB.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:catchall) do
    desc 'Allow catch all e-mail.'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:cgi) do
    desc 'Allow CGI access.'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:cron) do
    desc 'Allow cronjobs.'
    newvalues(:on, :off)
    defaultto :on
  end
  
  newproperty(:dnscontrol) do
    desc 'Allow DNS control.'
    newvalues(:on, :off)
    defaultto :on
  end
  
  newproperty(:domains) do
    desc 'Virtual domains allowed.'
    newvalues(:unlimited, /\d+/)
    defaultto :unlimited
  end
  
  newproperty(:domainptr) do
    desc 'Domain pointers.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:ftp) do
    desc 'FTP accounts.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:inodes) do
    desc 'Inodes.'
    newvalues(:unlimited, /\d+/)
    defaultto :unlimited
  end

  newproperty(:language) do
    desc 'The language.'
    validate do |value|
        raise Puppet::Error, "langue is #{value.length} characters long; must be of length 2 or greater" if value.length < 2
    end
  end
  
  newproperty(:login_keys) do
    desc 'Allow login keys.'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:mysql) do
    desc 'MySQL databases.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:nemailf) do
    desc 'E-mail forwarders.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:nemails) do
    desc 'E-mail forwarders.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:nemailml) do
    desc 'E-mail mailing lists.'
    newvalues(:unlimited, /\d+/)
    defaultto :unlimited
  end
  
  newproperty(:nemailr) do
    desc 'E-mail auto responders.'
    newvalues(:unlimited, /\d+/)
    defaultto :unlimited
  end
  
  newproperty(:nsubdomains) do
    desc 'Subdomains.'
    newvalues(:unlimited, /\d+/)
    defaultto 0
  end
  
  newproperty(:php) do
    desc 'PHP access'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:spamassassin) do
    desc 'SpamAssassin'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:ssl) do
    desc 'SSL access'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:ssh) do
    desc 'SSH access'
    newvalues(:on, :off)
    defaultto :off
  end
  
  newproperty(:sysinfo) do
    desc 'System Info'
    newvalues(:on, :off)
    defaultto :off
  end

  newproperty(:suspend_at_limit) do
    desc 'Suspend at limit'
    newvalues(:on, :off)
    defaultto :off
  end

  newproperty(:skin) do
    desc 'The skin\'s name.'
    validate do |value|
        raise Puppet::Error, "skin is #{value.length} characters long; must be of length 4 or greater" if value.length < 4
    end
  end
  
  newproperty(:quota) do
    desc 'Disk space.'
    newvalues(:unlimited, /\d+/)
    defaultto :unlimited
  end
  
  newparam(:api_username) do
    desc 'The username to connect to the API.'
    isrequired
    validate do |value|
      raise(Puppet::Error, "Empty values are not allowed") if value == ""
    end
  end
  
  newparam(:api_password) do
    desc 'The api_username\'s password to connect to the API.'
    isrequired
    validate do |value|
      raise(Puppet::Error, "Empty values are not allowed") if value == ""
    end
  end
  
  newparam(:api_hostname) do
    desc 'The API\'s endpoint. Do not specify the port here.'
    defaultto "localhost"
  end
  
  newparam(:api_port) do
    desc 'The API\'s endpoint\'s port.'
    defaultto "2222"
  end
end