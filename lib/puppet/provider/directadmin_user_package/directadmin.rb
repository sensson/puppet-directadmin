require File.expand_path(File.join(File.dirname(__FILE__), '..', 'directadmin'))
Puppet::Type.type(:directadmin_user_package).provide(:directadmin, :parent => Puppet::Provider::DirectAdmin) do
  def convert_package
    # We don't have support for personal DNS yet.
    package = {}
    package[:add] = "Save"
    package[:packagename]   = resource[:package_name]
    package[:skin]          = resource[:skin]
    package[:language]      = resource[:language]
    
    # Configurable resources
    package[:bandwidth]     = resource[:bandwidth] if resource[:bandwidth] != :unlimited
    package[:ubandwidth]    = "ON" if resource[:bandwidth] == :unlimited
    package[:domainptr]     = resource[:domainptr] if resource[:domainptr] != :unlimited
    package[:udomainptr]    = "ON" if resource[:domainptr] == :unlimited
    package[:ftp]           = resource[:ftp] if resource[:ftp] != :unlimited
    package[:uftp]          = "ON" if resource[:ftp] == :unlimited
    package[:inode]         = resource[:inodes] if resource[:inodes] != :unlimited
    package[:uinode]        = "ON" if resource[:inodes] == :unlimited
    package[:mysql]         = resource[:mysql] if resource[:mysql] != :unlimited
    package[:umysql]        = "ON" if resource[:mysql] == :unlimited
    package[:nemailf]       = resource[:nemailf] if resource[:nemailf] != :unlimited
    package[:unemailf]      = "ON" if resource[:nemailf] == :unlimited
    package[:nemails]       = resource[:nemails] if resource[:nemails] != :unlimited
    package[:unemails]      = "ON" if resource[:nemails] == :unlimited
    package[:nemailml]      = resource[:nemailml] if resource[:nemailml] != :unlimited
    package[:unemailml]     = "ON" if resource[:nemailml] == :unlimited
    package[:nemailr]       = resource[:nemailr] if resource[:nemailr] != :unlimited
    package[:unemailr]      = "ON" if resource[:nemailr] == :unlimited
    package[:nsubdomains]   = resource[:nsubdomains] if resource[:nsubdomains] != :unlimited
    package[:unsubdomains]  = "ON" if resource[:nsubdomains] == :unlimited
    package[:quota]         = resource[:quota] if resource[:quota] != :unlimited
    package[:uquota]        = "ON" if resource[:quota] == :unlimited
    package[:vdomains]      = resource[:domains] if resource[:domains] != :unlimited
    package[:uvdomains]     = "ON" if resource[:domains] == :unlimited
    
    # Resources that can be turned on or off
    resource[:aftp] == :on ? (package[:aftp] = "ON") : (package[:aftp] = "OFF")
    resource[:catchall] == :on ? (package[:catchall] = "ON") : (package[:catchall] = "OFF")
    resource[:cgi] == :on ? (package[:cgi] = "ON") : (package[:cgi] = "OFF")
    resource[:cron] == :on ? (package[:cron] = "ON") : (package[:cron] = "OFF")
    resource[:dnscontrol] == :on ? (package[:dnscontrol] = "ON") : (package[:dnscontrol] = "OFF")
    resource[:login_keys] == :on ? (package[:login_keys] = "ON") : (package[:login_keys] = "OFF")
    resource[:php] == :on ? (package[:php] = "ON") : (package[:php] = "OFF")
    resource[:spamassassin] == :on ? (package[:spam] = "ON") : (package[:spam] = "OFF")
    resource[:ssl] == :on ? (package[:ssl] = "ON") : (package[:ssl] = "OFF")
    resource[:ssh] == :on ? (package[:ssh] = "ON") : (package[:ssh] = "OFF")
    resource[:sysinfo] == :on ? (package[:sysinfo] = "ON") : (package[:sysinfo] = "OFF")
    resource[:suspend_at_limit] == :on ? (package[:suspend_at_limit] = "ON") : (package[:suspend_at_limit] = "OFF")
    
    @package_details = package
  end
  
  def create   
    connect
    convert_package
    set_package = self.class.post('CMD_API_MANAGE_USER_PACKAGES', @package_details)    
  end

  def destroy
    connect
    self.class.post('CMD_API_MANAGE_USER_PACKAGES',
      :delete     => "Delete",
      :delete0    => resource[:package_name]
    ) 
  end
  
  def exists?
    connect 
    packages = self.class.query('CMD_API_PACKAGES_USER')
    if packages.has_value?(resource[:package_name])
      @package_values = get_package_values
      @package_values["packagename"] = resource[:package_name]
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
  
  def connect_as_user
    self.class.connect(resource[:api_username] + "|" + resource[:username], resource[:api_password], resource[:api_hostname], resource[:api_port])
  end
  
  def get_package_values
    connect
    package = self.class.query('CMD_API_PACKAGES_USER',
      :package => resource[:package_name]
    )
    return package
  end
  
  def set_package_values
    connect
    convert_package
    set_package = self.class.post('CMD_API_MANAGE_USER_PACKAGES', @package_details)
    return true
  end
  
  # -----
  # Changing properties for this resource
  # -----
 
  def bandwidth
    package = @package_values
    return package["bandwidth"]
  end
  
  def bandwidth=(value)
    return set_package_values
  end
  
  def aftp
    package = @package_values
    return package["aftp"].downcase
  end
  
  def aftp=(value)
    return set_package_values
  end
  
  def catchall
    package = @package_values
    return package["catchall"].downcase
  end
  
  def catchall=(value)
    return set_package_values
  end
  
  def cgi
    package = @package_values
    return package["cgi"].downcase
  end
  
  def cgi=(value)
    return set_package_values
  end
  
  def cron
    package = @package_values
    return package["cron"].downcase
  end
  
  def cron=(value)
    return set_package_values
  end
  
  def domains
    package = @package_values
    return package["vdomains"]
  end
  
  def domains=(value)
    return set_package_values
  end
  
  def domainptr
    package = @package_values
    return package["domainptr"]
  end
  
  def domainptr=(value)
    return set_package_values
  end

  def dnscontrol
    package = @package_values
    return package["dnscontrol"].downcase
  end
  
  def dnscontrol=(value)
    return set_package_values
  end
  
  def ftp
    package = @package_values
    return package["ftp"]
  end
  
  def ftp=(value)
    return set_package_values
  end
  
  def inodes
    package = @package_values
    return package["inode"]
  end
  
  def inodes=(value)
    return set_package_values
  end
  
  def ips
    package = @package_values
    return package["ips"]
  end
  
  def ips=(value)
    return set_package_values
  end
  
  def login_keys
    package = @package_values
    return package["login_keys"].downcase
  end
  
  def login_keys=(value)
    return set_package_values
  end
  
  def language
    package = @package_values
    return package["language"]
  end
  
  def language=(value)
    return set_package_values
  end
  
  def mysql
    package = @package_values
    return package["mysql"]
  end
  
  def mysql=(value)
    return set_package_values
  end
  
  def nemailf
    package = @package_values
    return package["nemailf"]
  end
  
  def nemailf=(value)
    return set_package_values
  end
  
  def nemails
    package = @package_values
    return package["nemails"]
  end
  
  def nemails=(value)
    return set_package_values
  end
  
  def nemailml
    package = @package_values
    return package["nemailml"]
  end
  
  def nemailml=(value)
    return set_package_values
  end
  
  def nemailr
    package = @package_values
    return package["nemailr"]
  end
  
  def nemailr=(value)
    return set_package_values
  end
  
  def nsubdomains
    package = @package_values
    return package["nsubdomains"]
  end
  
  def nsubdomains=(value)
    return set_package_values
  end
  
  def php
    package = @package_values
    return package["php"].downcase
  end
  
  def php=(value)
    return set_package_values
  end
  
  def spamassassin
    package = @package_values
    return package["spam"].downcase
  end
  
  def spamassassin=(value)
    return set_package_values
  end
  
  def ssl
    package = @package_values
    return package["ssl"].downcase
  end
  
  def ssl=(value)
    return set_package_values
  end
  
  def ssh
    package = @package_values
    return package["ssh"].downcase
  end
  
  def ssh=(value)
    return set_package_values
  end
  
  def sysinfo
    package = @package_values
    return package["sysinfo"].downcase
  end
  
  def sysinfo=(value)
    return set_package_values
  end

  def suspend_at_limit
    package = @package_values
    return package["suspend_at_limit"].downcase
  end
  
  def suspend_at_limit=(value)
    return set_package_values
  end

  def skin
    package = @package_values
    return package["skin"]
  end
  
  def skin=(value)
    return set_package_values
  end
  
  def quota
    package = @package_values
    return package["quota"]
  end
  
  def quota=(value)
    return set_package_values
  end

end
