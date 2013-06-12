require 'logstash/filters/base'
require 'logstash/namespace'
require 'json'
require 'rest-client'
require 'uri'
require 'ipaddr'

class LogStash::Filters::Ip2store < LogStash::Filters::Base
  config_name "ip2store"
  plugin_status "experimental"
  
  # The field name that contains an IP address to get store number from
  config :field, :validate => :string
  
  # The service bus URL for ip2store calls
  config :service_bus_url, :validate => :string
  
  # The api key for service bus
  config :api_key, :validate => :string
  
  # Specify into what field you want the store number placed.
  config :target, :validate => :string, :default => 'store'
  
  public
  def register
    @store_info = Hash.new({})
    
    @logger.debug "Registered ip2store plugin", :config => @config
  end
  
  public
  def filter(event)
    addr = event[@field]
    addr_short = to_three_octets addr
    full_url = URI.join(@service_bus_url, addr + "/").to_s
    
    if validate_addr addr
      begin
        if @store_info[addr_short].empty? || expired(@store_info[addr_short][:timestamp])
          @logger.debug "Retrieving store number from Service Bus"
          
          response = RestClient.get full_url, :X_API_Key => @api_key
          data = JSON.parse(response)
          event[@target] = data['storeNumber']
          
          cache_info addr_short, data['storeNumber']
          
        else
          @logger.debug "Retrieving store number from the cache"
          
          event[@target] = @store_info[addr_short][:store_number]
        end
        
      rescue SocketError => e
        @logger.error "Could not find the Service Bus server. Please check DNS and verify the 'service_bus_url' configuration setting"
        
      rescue RestClient::BadGateway => e
        @logger.error "Could not contact the Service Bus server.  Please check that Service Bus server is running, firewalls are not blocking the connection, and verify the 'service_bus_url' configuration setting"
  
      rescue Exception => e
        @logger.error e
      
      end
    end
  end
  
  # Split off the last octet so we're left with the first 3 octets
  private
  def to_three_octets(addr)
    addr.rpartition(".")[0]
  end  
  
  # Cache the store number with a key of the first 3 octets of the IP. Set timestamp to now.
  private 
  def cache_info(addr, store_number) 
    @store_info[addr] = { :store_number => store_number, :timestamp => Time.now.to_i }
  end
  
  # Given a timestamp from the cache, determine if it's been more than 24 hours
  private
  def expired(timestamp)
    timestamp.to_i + 86400 < Time.now.to_i ? true : false
  end
  
  # Validate an IP address
  private
  def validate_addr(addr)
    begin
      IPAddr.new addr
    
    rescue ArgumentError => e
      @logger.error "Invalid IP address in field '@field'"
      false
    else
      true
    end
  end
end