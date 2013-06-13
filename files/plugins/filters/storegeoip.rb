require 'logstash/filters/base'
require 'logstash/namespace'
require 'json'
require 'rest-client'
require 'uri'

class LogStash::Filters::StoreGeoIP < LogStash::Filters::Base
  config_name "storegeoip"
  plugin_status "experimental"
  
  # The field name that contains the store number
  config :field, :validate => :string
  
  # The service bus URL for ip2store calls
  config :service_bus_url, :validate => :string
  
  # The api key for service bus
  config :api_key, :validate => :string
  
  # Specify into what field you want the store number placed.
  config :target, :validate => :string, :default => 'geopoint'
  
  public
  def register
    @store_location = Hash.new({})
    
    @logger.debug "Registered storegeoip plugin", :config => @config
  end
  
  public
  def filter(event)
    return unless filter?(event)
    
    store_number = event[@field]
    store_number = store_number.first if addr.is_a? Array
    store_number = store_number.to_i
    full_url = URI.join(@service_bus_url, store_number.to_s + "/").to_s
    event[@target] = {} if event[@target].nil?
    
    begin
      if @store_location[store_number].empty? || expired(@store_location[store_number][:timestamp])
        @logger.debug "Retrieving store location from Service Bus"
          
        response = RestClient.get full_url, :X_API_Key => @api_key
        data = JSON.parse(response)
        event[@target]['lat'] = to_geopoint(data['geoLatitude'])
        event[@target]['lon'] = to_geopoint(data['geoLongitude'])
        
        cache_location store_number, to_geopoint(data['geoLatitude']), to_geopoint(data['geoLongitude'])
         
        else
        @logger.debug "Retrieving store location from the cache"
        
        event[@target]['lat'] = @store_location[store_number][:lat]
        event[@target]['lon'] = @store_location[store_number][:lon]
      end
      
      filter_matched(event)
      
    rescue SocketError => e
      @logger.error "Could not find the Service Bus server. Please check DNS and verify the 'service_bus_url' configuration setting"
        
     rescue RestClient::BadGateway => e
      @logger.error "Could not contact the Service Bus server.  Please check that Service Bus server is running, firewalls are not blocking the connection, and verify the 'service_bus_url' configuration setting"
        
    rescue Exception => e
      @logger.error e
        
    end
  end
  
  # Cache the store location with a key of store number. Set timestamp to now.
  private
  def cache_location(store_number, lat, lon)
    @store_location[store_number] = { :lat => lat, :lon => lon, :timestamp => Time.now.to_i }
  end
  
  # Given a timestamp from the cache, determine if it's been more than 24 hours
  private
  def expired(timestamp)
    timestamp.to_i + 86400 < Time.now.to_i ? true : false
  end
  
  # Convert lat/lon to geopoint lat/lon
  private
  def to_geopoint(point)
    (point * 1E6).floor
  end
end