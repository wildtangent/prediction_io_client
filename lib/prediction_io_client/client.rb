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
      
      def identify(uid)
        @uid = uid
      end
      
      def get_status
        @connection.get("/").body
      end
      
      def create_user(uid, params={})
        params.merge!(default_params)
        params['pio_uid'] = uid
        extract_latlng(params)
        @connection.post(:users, params).body
      end
  
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
      
      def delete_user(uid)
        params = {"pio_uid" => uid}.merge(default_params)
        @connection.delete(:users, uid, params).body
      end

      def create_item(iid, itypes, params={})
        params.merge!(default_params)
        params['pio_iid'] = iid
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        @connection.post(:items, params).body
      end 
      
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
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        response = @connection.get(:engines, :itemrec, engine, :topn, params)
        response.body["pio_iids"]
      end
      
      def get_itemsim_top_n(engine, n, params)
        params.merge!(default_params)
        params['pio_uid'] = @uid
        params['pio_n'] = n
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        response = @connection.get(:engines, :itemsim, engine, :topn, params)
        response.body["pio_iids"]
      end
      
      def record_action_on_item(action, iid, params={})
        params.merge!(default_params)
        params['action'] = action
        params['pio_uid'] = @uid
        params['pio_iid'] = iid
        params["pio_t"] = ((params["pio_t"].to_r) * 1000).round(0).to_s if params["pio_t"]
        extract_latlng(params)
        @connection.post(:actions, :u2i, params).body
      end
      
      private
      
      
      def extract_latlng(params)
        lat = params.delete('pio_latitude')
        lng = params.delete('pio_longitude')
        params['pio_latlng'] = "#{lat},#{lng}" if lat && lng
        return params['pio_latlng']
      end
      
      def extract_startend(params)
        params["pio_startT"] = ((params["pio_startT"].to_r) * 1000).round(0).to_s if params["pio_startT"]
        params["pio_endT"] = ((params["pio_endT"].to_r) * 1000).round(0).to_s if params["pio_endT"]
      end
      
      def format_itypes(itypes, params)
        case itypes
        when Array
          params['pio_itypes'] = itypes.join(",") if itypes.any?
        when String
          params['pio_itypes'] = itypes
        end
      end
      
      def default_params
        {
          "pio_appkey" => @app_key
        }
      end
      
    end
  
  end
end