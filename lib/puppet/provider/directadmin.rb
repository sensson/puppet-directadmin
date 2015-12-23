require 'net/http'
require 'uri'

# This class currently has some duplicate code in it, this needs cleaning up.
class Puppet::Provider::DirectAdmin < Puppet::Provider
  initvars
  
  class Error < ::StandardError
  end
  
  def self.connect(username, password, hostname, port)
    @auth_username = username
    @auth_password = password
    @http = Net::HTTP.new(hostname, port)
  end
  
  # We need to allow post requests to the API for certain actions such as removing accounts.
  def self.post(uri, *args)
    options = args.first || {}
    uri = "/#{uri}"
    resp = ""
    
    @http.start() { |http|
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(options)
      req.basic_auth @auth_username, @auth_password
      response = http.request(req)
      # URI.unescape misses a lot, for some reason.
      resp = URI.unescape(response.body).gsub("&#45","-").gsub("&#64", "@").gsub("&#95", "_").gsub("&#58", ":")
    }
    
    # Create a hash of the response. We need some additional magic to make sure lists are parsed properly.
    resp_hash = {}
    response = resp.split('&')
    i = 0
    response.each do |var|
      key,value = var.split("=")
      if key == "list[]"
        key = i
        i += 1
      end
      resp_hash[key] = value
    end
      
    if resp_hash["error"] == "1"
      text = resp_hash["text"]
      details = resp_hash["details"]
      raise(Puppet::Error, "#{text}. #{details}.")
    elsif resp =~ /DirectAdmin\ Login/
      raise(Puppet::Error, "Login failed. The specified username and/or password is not correct.")
    elsif resp =~ /authority\ level/
      raise(Puppet::Error, "The request you've made cannot be executed because it does not exist in your authority level.")
    else
      return resp_hash
    end
  end
  
  # In most cases we can send a GET request to DirectAdmin to do what we want.
  def self.query(uri, *args)
    options = args.first || {}
    params = ""
    options.each do |o|
      params << "#{o[0]}=#{o[1]}&"
    end
    uri = "/#{uri}?#{params}api=yes"
    resp = ""
    
    @http.start() { |http|
      req = Net::HTTP::Get.new(uri)
      req.basic_auth @auth_username, @auth_password
      response = http.request(req)
      # URI.unescape misses a lot, for some reason.
      resp = URI.unescape(response.body).gsub("&#45","-").gsub("&#64", "@").gsub("&#95", "_").gsub("&#58", ":")
    }
      
    # Create a hash of the response. We need some additional magic to make sure lists are parsed properly.
    resp_hash = {}
    response = resp.split('&')
    i = 0
    response.each do |var|
      key,value = var.split("=")
      if key == "list[]"
        key = i
        i += 1
      end
      resp_hash[key] = value
    end
      
    if resp_hash["error"] == "1"
      text = resp_hash["text"]
      details = resp_hash["details"]
      raise(Puppet::Error, "#{text}. #{details}.")
    elsif resp =~ /DirectAdmin\ Login/
      raise(Puppet::Error, "Login failed. The specified username and/or password is not correct.")
    elsif resp =~ /authority\ level/
      raise(Puppet::Error, "The request you've made cannot be executed because it does not exist in your authority level.")
    else
      return resp_hash
    end
  end
end
