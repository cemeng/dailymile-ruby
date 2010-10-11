require 'forwardable'

module Dailymile
  
  DEFAULT_FORMAT = 'json'
  STREAM_FILTERS = %w(nearby popular)
  
  class Client
    extend Forwardable
    
    attr_reader :access_token
    def_delegators :access_token, :get, :post, :put, :delete
    
    def self.set_client_credentials(client_id, client_secret)
      @@client = OAuth2::Client.new(client_id, client_secret,
        :site => BASE_URI,
        :access_token_path => OAUTH_TOKEN_PATH,
        :authorize_path => OAUTH_AUTHORIZE_PATH
      )
    end
    
    def initialize(token = nil)
      @@client ||= OAuth2::Client.new('', '', :site => BASE_URI) # HACK: dummy client
      
      @access_token = Token.new(@@client, token)
    end
    
    # EXAMPLES:
    #   everyone stream: client.entries
    #   nearby stream: client.entries :nearby, 37.77916, -122.420049, :page => 2
    #   ben's stream: client.entries :ben, :page => 2
    def entries(*args)
      params = extract_options_from_args!(args)
      filter = args.shift
    
      entries_path = case filter
      when String, Symbol
        filter = filter.to_s.strip
    
        if STREAM_FILTERS.include?(filter)
          if filter == 'nearby'
            lat, lon = args
            "/entries/nearby/#{lat},#{lon}"
          else
            "/entries/#{filter}"
          end
        else
          "/people/#{filter}/entries"
        end
      else
        '/entries'
      end
    
      data = get entries_path, params
      data["entries"]
    end
    
  private
    
    def extract_options_from_args!(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end
    
  end
  
end