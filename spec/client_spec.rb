require 'spec_helper'
require 'yaml'
require 'active_support/all'

describe FM::PredictionIO::Client do
  
  let :config do
    YAML.load_file("config.yml").symbolize_keys
  end
  
  let :api_key do 
    config[:api_key]
  end
  
  let :api_url do
    config[:api_url]
  end
  
  let :itemsim_engine do
    config[:itemsim_engine]
  end
  
  let :itemrec_engine do
    config[:itemrec_engine]
  end
  
  let :client do
    FM::PredictionIO::Client.new(api_key, api_url)
  end
  
  let :uid do
    2345
  end
  
  let :iid do
    4567
  end
  
  it 'should return an OK message' do
    client.get_status.should eq 'PredictionIO Output API is online.'
  end
  
  context 'creating users' do
  
    after :each do
      client.delete_user(uid)
    end
  
    it 'should create a user' do
      client.create_user(uid).should eq({'message' => "User created."})
    end
    
    it 'should get a user by their uid' do
      client.create_user(uid)
      client.get_user(uid)["pio_uid"].should eq uid.to_s
    end
    
    it 'should create a user with lat/lng co-ordinates' do
      client.create_user(uid, "pio_latitude" => 0.56, "pio_longitude" => 0.0)
      client.get_user(uid).should eq({
        "pio_uid" => uid.to_s,
        "pio_latlng" => [0.56, 0.0],
        "pio_latitude" => 0.56,
        "pio_longitude" => 0.0
      })
    end
  
  end
  
  context 'deleting users' do
    it 'should delete a user' do
      client.create_user(uid)
      client.delete_user(uid).should eq({'message' => 'User deleted.'})
    end
  end
  
  context 'creating items' do
    
    after :each do
      client.delete_item(iid)
    end

    it 'should create an item with a string item type' do
      client.create_item(iid, 'camera').should eq({'message' => 'Item created.'})
    end
  
    it 'should create an item with an array item type' do
      client.create_item(iid, ['dvd-player', 'bluray-player']).should eq({'message' => 'Item created.'})
      client.get_item(iid).should include({
        'pio_iid' => iid.to_s,
        "pio_itypes" => ['dvd-player', 'bluray-player']
      })
    end
  
    it 'should get an item by its iid' do
      client.create_item(iid, 'camera')
      client.get_item(iid).should include({
        "pio_iid" => iid.to_s,
        "pio_itypes" => ["camera"]
      })
    end
    
    it 'should create an item with lat/lng co-ordinates' do
      client.create_item(iid, 'country', "pio_latitude" => 0.765, "pio_longitude" => 0.234)
      client.get_item(iid).should include({
        "pio_iid" => iid.to_s,
        'pio_itypes' => ['country'],
        "pio_latlng" => [0.765, 0.234],
        "pio_latitude" => 0.765,
        "pio_longitude" => 0.234
      })
    end
    
    it 'should create an item with start and end times' do
      start_time = 1.day.ago
      end_time = 1.day.from_now
      client.create_item(iid, 'daily-deal', "pio_startT" => start_time, "pio_endT" => end_time)
      item = client.get_item(iid)
      item.should include({
        "pio_iid" => iid.to_s
      })
      item['pio_startT'].to_s.should eq start_time.to_s
      item['pio_endT'].to_s.should eq end_time.to_s
    end
  end
  
  context 'deleting items' do
    it 'should delete an item' do
      client.create_item(iid, 'camera')
      client.delete_item(iid).should eq({'message' => "Item deleted."})
    end
  end
  
  context 'record user action on an item' do
    
    before :each do
      client.create_user(uid)
      client.create_item(iid, 'camera')
    end
    
    after :each do
      client.delete_user(uid)
      client.delete_item(iid)
    end
    
    it 'should record an action' do
      client.identify(uid)
      client.record_action_on_item('view', iid).should eq({
        "message" => 'Action view recorded.'
      })
    end
    
    it 'should record an action with a specific timestamp' do
      client.identify(uid)
      client.record_action_on_item("view", iid, 'pio_t' => 1.month.ago).should eq({
        "message" => "Action view recorded."
      })
    end
    
    it 'should record a rating on an item' do
      client.identify(uid)
      client.record_action_on_item("rate", iid, "pio_rate" => 3).should eq({
        "message" => "Action rate recorded."
      })
    end
    
    it 'should record an action with a latitude and longitude' do
      client.identify(uid)
      client.record_action_on_item("like", iid, "pio_latitude" => 51.4, "pio_longitude" => 23.4).should eq({
        "message" => "Action like recorded."
      })
    end
  end
  
  context 'recommending items' do
    
    before :each do
      client.create_user(uid)
      client.create_user(uid+1)
      client.create_item(iid, 'camera')
      client.create_item(iid+1, 'camera')
      client.create_item(iid+2, 'camera')
      client.identify(uid)
      client.record_action_on_item('like', iid)
      client.record_action_on_item('like', iid+1)
      client.record_action_on_item('dislike', iid+2)
      
      client.identify(uid+1)
      client.record_action_on_item('like', iid)
    end
    
    after :each do
      client.delete_user(uid)
      client.delete_user(uid+1)
      client.delete_item(iid)
      client.delete_item(iid+1)
      client.delete_item(iid+2)

    end
    
    it 'should recommend using item similarity' do
      client.identify(uid+1)
      expect { client.get_itemsim_top_n(itemsim_engine, iid, 5) }.to raise_error Faraday::Error::ResourceNotFound
    end
    
    it 'should recommend using user recommendation' do
      client.identify(uid+1)
      expect { client.get_itemrec_top_n(itemrec_engine, 5) }.to raise_error Faraday::Error::ClientError
    end
    
  end

end