require File.expand_path(File.join(File.dirname(__FILE__), '..', 'directadmin'))
Puppet::Type.type(:directadmin_admin).provide(:directadmin, :parent => Puppet::Provider::DirectAdmin) do
  def create
    connect
    self.class.query('CMD_API_ACCOUNT_ADMIN',
      :action     => "create",
      :add        => "Submit",
      :username   => resource[:username],
      :email      => resource[:email],
      :passwd     => resource[:password],
      :passwd2    => resource[:password],
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
    admins = self.class.query('CMD_API_SHOW_ADMINS') 
    if admins.has_value?(resource[:username])
      return true
    else
      return false
    end
  end
  
  # -----
  # Custom functions
  # -----
  
  def connect
    self.class.connect(resource[:api_username], resource[:api_password], resource[:api_hostname], resource[:api_port], resource[:api_ssl])
  end
  
  def connect_as_user
    self.class.connect(resource[:api_username] + "|" + resource[:username], resource[:api_password], resource[:api_hostname], resource[:api_port], resource[:api_ssl])
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
    password = self.class.query('CMD_API_VERIFY_PASSWORD',
      :user       => resource[:username],
      :passwd     => resource[:password]
    )
    if password["valid"] == "1"
      return resource[:password]
    else
      return "********"
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
