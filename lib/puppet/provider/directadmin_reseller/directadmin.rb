require 'puppet/provider/directadmin'
Puppet::Type.type(:directadmin_reseller).provide :directadmin, :parent => Puppet::Provider::Directadmin do  
  def create   
    connect
    self.class.query('CMD_API_ACCOUNT_RESELLER',
      :action     => "create",
      :add        => "Submit",
      :username   => resource[:username],
      :email      => resource[:email],
      :passwd     => resource[:password],
      :passwd2    => resource[:password],
      :domain     => resource[:domain],
      :package    => resource[:user_package],
      :ip         => resource[:ip_address],
      :notify     => resource[:notifications]
    )
  end

  def destroy
    connect
    self.class.post('CMD_API_SELECT_USERS',
      :confirmed  => "Confirmed",
      :delete     => "yes",
      :select0    => resource[:username]
    )
  end
  
  def exists?
    connect
    resellers = self.class.query('CMD_API_SHOW_RESELLERS')
    if resellers.has_value?(resource[:username])
      return true
    else
      return false
    end
  end
  
  # -----
  # Custom functions
  # -----
  
  def connect
    self.class.connect(resource[:api_username], resource[:api_password], resource[:api_hostname], resource[:api_port])
  end
  
  # -----
  # Changing properties for this resource
  # -----
  
  # Change the e-mail address for a particular user.
  def email
    connect
    user = self.class.query('CMD_API_SHOW_USER_CONFIG',
      :user     => resource[:username]
    )
    return user["email"] 
  end
  
  def email=(value)
    connect
    info = self.class.post('CMD_API_MODIFY_USER',
      :action   => "single",
      :user     => resource[:username],
      :evalue   => resource[:email],
      :email    => "Save"
    )
    return true
  end
  
  # Change the password for the admin user.
  def password
    connect
    current_password = self.class.query('CMD_API_VERIFY_PASSWORD',
      :user       => resource[:username],
      :passwd     => resource[:password]
    )
    
    if current_password["valid"] == "1"
      return resource[:password]
    else
      return "password"
    end
  end
  
  def password=(value)
    connect
    self.class.post('CMD_API_USER_PASSWD',
      :username   => resource[:username],
      :passwd     => resource[:password],
      :passwd2    => resource[:password]
    )
  end
end