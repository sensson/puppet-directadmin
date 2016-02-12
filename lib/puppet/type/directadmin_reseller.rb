Puppet::Type.newtype(:directadmin_reseller) do
  @doc = "Manage DirectAdmin resellers."
  
  ensurable
  
  # The following parameters are required.
  validate do
    fail('password parameter is required.') if self[:ensure] == :present and self[:password].nil?
    fail('email parameter is required.') if self[:ensure] == :present and self[:email].nil?
    fail('domain parameter is required.') if self[:ensure] == :present and self[:domain].nil?
    fail('user_package parameter is required.') if self[:ensure] == :present and self[:user_package].nil?
    fail('api_username parameter is required.') if self[:api_username].nil?
    fail('api_password parameter is required.') if self[:api_password].nil?
  end
  
  newparam(:username, :namevar => true) do
    desc 'The reseller\'s name.'
    validate do |value|
        raise Puppet::Error, "username is #{value.length} characters long; must be of length 4 or greater" if value.length < 4
    end
  end
  
  newproperty(:password) do
    desc 'The reseller\'s password.'
    isrequired
    validate do |value|
        raise Puppet::Error, "password is #{value.length} characters long; must be of length 6 or greater" if value.length < 6
    end
  end
  
  newproperty(:email) do
    desc 'The reseller\'s e-mail address.'
    isrequired
    validate do |value|
      unless (value =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
        raise(Puppet::Error, "The e-mail address '#{value}' is invalid.")
      end
    end
  end
  
  newparam(:domain) do
    desc "The reseller's domain name."
    isrequired
    validate do |value|
      raise(Puppet::Error, "Empty values are not allowed") if value == ""
    end
  end
  
  newparam(:ip_address) do
    desc "Set the type of IP address."
    newvalues(:shared, :sharedreseller, :assign)
    defaultto :shared
  end
  
  newparam(:notifications) do
    desc "Send a notification e-mail, or not."
    newvalues(:no, :yes)
    defaultto :no
  end
  
  newparam(:user_package) do
    desc 'The package that will be used for the reseller.'
    isrequired
    validate do |value|
      raise(Puppet::Error, "Empty values are not allowed") if value == ""
    end
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

  newparam(:api_ssl) do
    desc 'Connect to the API over SSL.'
    defaultto :false
  end

end
