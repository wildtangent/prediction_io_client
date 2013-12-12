require 'spec_helper'
require 'yaml'

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
    
  end
  
  context 'deleting items' do
    it 'should delete an item' do
      client.create_item(iid, 'camera')
      client.delete_item(iid).should eq({'message' => "Item deleted."})
    end
  end
  
  
  
  
end