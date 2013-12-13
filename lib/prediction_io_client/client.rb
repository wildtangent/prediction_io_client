module FM
  
  module PredictionIO
    
    class Client
      
      def initialize(app_key, api_url="http://localhost:8000", api_version='')
        @app_key = app_key
        @api_url = api_url
        @api_version = api_version
        @api_format = 'json'
        @connection = Connection.new(@api_url, @api_format, @api_version)
      end
      
      # Set the current user for the client. Item Recommendations will use this to scope their results
      def identify(uid)
        @uid = uid
      end
      
      # Return the status of the Prediction.IO server instance
      def get_status
        @connection.get("/").body
      end
      
      # Create a user by their user ID, with optional pio_latitude, pio_longitude, 
      # pio_inactive, and any othe optional attributes
      def create_user(uid, params={})
        params.merge!(default_params)
        params['pio_uid'] = uid
        extract_latlng(params)
        @connection.post(:users, params).body
      end
  
      # Get a user by their user ID
      def get_user(uid)
        params = {"pio_uid" => uid}.merge(default_params)
        response = @connection.get(:users, uid, params).body
        if response["pio_latlng"]
          latlng = response["pio_latlng"]
          response["pio_latitude"] = latlng[0]
          response["pio_longitude"] = latlng[1]
        end
        response      
      end

      # Delete a user by their user ID
      def delete_user(uid)
        params = {"pio_uid" => uid}.merge(default_params)
        @connection.delete(:users, uid, params).body
      end

      # Create an item by id, types[] and optional attributes
      def create_item(iid, itypes, params={})
        params.merge!(default_params)
        params['pio_iid'] = iid
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        @connection.post(:items, params).body
      end 

      # Get an item from the Prediction.IO server by its item id
      def get_item(iid)
        params = {'pio_iid' => iid}.merge(default_params)
        response = @connection.get(:items, iid, params).body
        if response["pio_latlng"]
          latlng = response["pio_latlng"]
          response["pio_latitude"] = latlng[0]
          response["pio_longitude"] = latlng[1]
        end
        if response["pio_startT"]
          startT = Rational(response["pio_startT"], 1000)
          response["pio_startT"] = Time.at(startT)
        end
        if response["pio_endT"]
          endT = Rational(response["pio_endT"], 1000)
          response["pio_endT"] = Time.at(endT)
        end
        response
      end
      
      # Remove an item from the Prediction.IO server by its item id
      def delete_item(iid)
        params = {'pio_iid' => iid}.merge(default_params)
        @connection.delete(:items, iid, params).body
      end
      
      # Options: pio_uid, pio_n, pio_itypes, pio_latitude, pio_longitude, pio_within, pio_unit
      # Should probably reject others!
      def get_itemrec_top_n(engine, n, params={})
        params.merge!(default_params)
        params['pio_uid'] = @uid
        params['pio_n'] = n
        itypes = params.delete("pio_itypes")
        format_itypes(itypes, params)
        extract_latlng(params)
        response = @connection.get(:engines, :itemrec, engine, :topn, params)
        response.body["pio_iids"]
      end
      
      # Options: pio_iid, pio_n, pio_itypes, pio_latitude, pio_longitude, pio_within, pio_unit
      # Should probably reject others!
      def get_itemsim_top_n(engine, iid, n, params={})
        params.merge!(default_params)
        params['pio_iid'] = iid
        params['pio_n'] = n
        itypes = params.delete("pio_itypes")
        format_itypes(itypes, params)
        extract_latlng(params)
        response = @connection.get(:engines, :itemsim, engine, :topn, params)
        response.body["pio_iids"]
      end
      
      # Allowed actions: view, like, dislike, rate, conversion
      # Optionally accepts 
      # pio_t which is a date/time when the action took place
      # pio_rate which is used when the rate action is specified
      # pio_latitude, pio_longitude for location
      # And any other params you want to set on the action as key value pairs
      def record_action_on_item(action, iid, params={})
        params.merge!(default_params)
        params['pio_action'] = action
        params['pio_uid'] = @uid
        params['pio_iid'] = iid
        params["pio_t"] = ((params["pio_t"].to_r) * 1000).round(0).to_s if params["pio_t"]
        extract_latlng(params)
        @connection.post(:actions, :u2i, params).body
      end
      
      private
      
      # Create the correct parameter key for lat/lng from the supplied separatelat/lng params
      def extract_latlng(params)
        lat = params.delete('pio_latitude')
        lng = params.delete('pio_longitude')
        params['pio_latlng'] = "#{lat},#{lng}" if lat && lng
        return params['pio_latlng']
      end
      
      # Create the correct parameters for startT and endT
      def extract_startend(params)
        params["pio_startT"] = ((params["pio_startT"].to_r) * 1000).round(0).to_s if params["pio_startT"]
        params["pio_endT"] = ((params["pio_endT"].to_r) * 1000).round(0).to_s if params["pio_endT"]
      end
      
      # Handle both string and array types
      def format_itypes(itypes, params)
        case itypes
        when Array
          params['pio_itypes'] = itypes.join(",") if itypes.any?
        when String
          params['pio_itypes'] = itypes
        end
      end
      
      # Default params to always send with the client requests
      def default_params
        {
          "pio_appkey" => @app_key
        }
      end
      
    end
  
  end
end