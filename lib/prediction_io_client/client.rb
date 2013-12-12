module FM
  
  module PredictionIO
    
    class Client
      def initialize(app_key, api_url="http://localhost:8000", api_version='')
        @app_key = app_key
        @api_url = api_url
        @api_version = api_version
        @api_format = 'json'
        @http = Connection.new(@api_url, @api_format, @api_version)
      end
      
      def get_status
        @http.connection.get("/").body
      end
      
      def create_user(uid, params={})
        params.merge!(default_params)
        params['pio_uid'] = uid
        extract_latlng(params)
        @http.post(:users, params)
      end
  
      def get_user(uid)
        params = {"pio_uid" => uid}.merge(default_params)
        response = @http.get(:users, uid, params)
        response.body["pio_uid"]
      end
      
      def delete_user(uid)
        params = {"pio_uid" => uid}.merge(default_params)
        @http.delete(:users, uid, params).body
      end

      def create_item(iid, itypes, params={})
        params.merge!(default_params)
        params['pio_iid'] = iid
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        @http.post(:items, params).body
      end 
      
      def get_item(iid)
        params = {'pio_iid' => iid}.merge(default_params)
        @http.get(:items, iid, params).body
      end
      
      def delete_item(iid)
        params = {'pio_iid' => iid}.merge(default_params)
        @http.delete(:items, iid, params).body
      end
      
      
      # Options: pio_uid, pio_n, pio_itypes, pio_latitude, pio_longitude, pio_within, pio_unit
      # Should probably reject others!
      def get_itemrec_top_n(engine, uid, n, params={})
        params.merge!(default_params)
        params['pio_uid'] = uid
        params['pio_n'] = n
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        @http.get(:engines, :itemrec, engine, :topn, params).body
      end
      
      def get_itemsim_top_n(engine, uid, n, params)
        params.merge!(default_params)
        params['pio_uid'] = uid
        params['pio_n'] = n
        params['pio_uid'] = uid
        params['pio_n'] = n
        format_itypes(itypes, params)
        extract_latlng(params)
        extract_startend(params)
        @http.get(:engines, :itemsim, engine, :topn, params).body
      end
      
      def record_action_on_item(action, uid, iid, params={})
        params.merge!(default_params)
        params['action'] = action
        params['pio_uid'] = uid
        params['pio_iid'] = iid
        params["pio_t"] = ((params["pio_t"].to_r) * 1000).round(0).to_s if params["pio_t"]
        extract_latlng(params)
        @http.post(:actions, :u2i, params).body
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
      
      def versioned_path(path)
        #disabled for now
        path
      end
      
    end
  
  end
end