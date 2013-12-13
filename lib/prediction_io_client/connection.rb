module FM
  
  module PredictionIO
    
    class Connection
      
      require 'faraday'
      require 'faraday_middleware'
      require 'active_support/core_ext/array'
      
      @@debug = false
            
      attr_accessor :connection
      
      # Pass in the endpoing, format and version (currently not implemented, as in the original library)
      def initialize(api_url, api_format='json', api_version="")
        @api_url = api_url
        @api_format = api_format
        @api_version = api_version
        @connection = setup_connection
      end
      
      # Get a request from the API endpoint
      def get(*args)
        params = args.extract_options!
        @connection.get do |req|
          req.url versioned_path(args), params
        end
      end
      
      # POST a request to the API endpoint
      def post(*args)
        params = args.extract_options!
        @connection.post do |req|
          req.url versioned_path(args)
          req.body = params
        end
      end
      
      # DELETE request to the API endpoint
      def delete(*args)
        params = args.extract_options!
        @connection.delete do |req|
          req.url versioned_path(args)
          req.body = params
        end
      end
      
      
      private
      
      # Build up the API request path from the parts
      def versioned_path(args)
        return args.first if args == ['/']
        path = args.flatten.join("/")
        [path, @api_format].join(".")
      end
      
      # Set up Faraday with the appropriate middlewares
      def setup_connection
        Faraday.new(:url => @api_url) do |connection|
          #connection.request :url_encoded
          connection.request :json
          #connection.request :retry
          
          connection.response :logger if debug?
          connection.response :raise_error
          connection.response :json, :content_type => /\bjson$/
          
          connection.use :instrumentation
          connection.adapter Faraday.default_adapter
        end
      end
      
      # Whether to perform debug logging on the connection object
      def debug?
        @@debug
      end
        
      
    end
    
  end
  
end